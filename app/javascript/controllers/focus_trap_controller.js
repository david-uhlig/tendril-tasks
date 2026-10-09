import { Controller } from "@hotwired/stimulus"

const FOCUSABLE = [
  "a[href]",
  "area[href]",
  "button:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "[contenteditable]:not([contenteditable='false'])",
  "[tabindex]"
].join(",")

// Connects to data-controller="focus-trap"
/**
 * This Stimulus controller, `FocusTrapController`, keeps keyboard focus within a modal while it
 * is shown, so keyboard users can't reach the page behind a modal that blocks outside interaction.
 *
 * - Moves focus into the modal when it opens, unless focus is already inside.
 * - Tab on the last and Shift+Tab on the first focusable element wrap around.
 * - Moves focus back into the modal when it leaves the modal anyway.
 * - Returns focus to the previously focused element when the modal is hidden.
 *
 * The controller watches the `hidden` class of its element, which Flowbite toggles when showing or
 * hiding a modal.
 *
 * Usage:
 * - Add `data-controller="focus-trap"` to the modal element.
 */
export default class extends Controller {
  connect() {
    this.keydown = this._keydown.bind(this)
    this.focusin = this._focusin.bind(this)

    this.visible = false
    this.observer = new MutationObserver(() => this._visibilityChanged())
    this.observer.observe(this.element, { attributes: true, attributeFilter: [ "class" ] })
    this._visibilityChanged()
  }

  disconnect() {
    this.observer?.disconnect()
    this._deactivate()
  }

  /**
   * Activates the trap when the modal becomes visible and deactivates it when the modal is hidden.
   * @private
   */
  _visibilityChanged() {
    const visible = !this.element.classList.contains("hidden")
    if (visible === this.visible) return

    this.visible = visible
    visible ? this._activate() : this._deactivate(true)
  }

  /**
   * @private
   */
  _activate() {
    this.previousFocusedElement = document.activeElement
    document.addEventListener("keydown", this.keydown, true)
    document.addEventListener("focusin", this.focusin)

    // Wait a frame so controllers inside the modal, like auto-focus, may focus an element first
    this.frame = requestAnimationFrame(() => {
      if (!this.element.contains(document.activeElement)) this._focusFirst()
    })
  }

  /**
   * @param {boolean} returnFocus whether to focus the element that was focused before the modal opened
   * @private
   */
  _deactivate(returnFocus = false) {
    cancelAnimationFrame(this.frame)
    document.removeEventListener("keydown", this.keydown, true)
    document.removeEventListener("focusin", this.focusin)

    const previous = this.previousFocusedElement
    this.previousFocusedElement = null
    if (returnFocus && previous?.isConnected && previous !== document.body) previous.focus()
  }

  /**
   * Wraps Tab and Shift+Tab around the first and last focusable elements of the modal.
   * @param {KeyboardEvent} event
   * @private
   */
  _keydown(event) {
    if (event.key !== "Tab" || event.defaultPrevented) return

    const elements = this._focusableElements()
    if (elements.length === 0) {
      event.preventDefault()
      this.element.focus()
      return
    }

    const first = elements[0]
    const last = elements[elements.length - 1]
    const active = document.activeElement
    const inside = this.element.contains(active)

    if (event.shiftKey && (!inside || active === first || active === this.element)) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && (!inside || active === last)) {
      event.preventDefault()
      first.focus()
    }
  }

  /**
   * Moves focus back into the modal when it lands outside, e.g. through a screen reader.
   * @param {FocusEvent} event
   * @private
   */
  _focusin(event) {
    if (!this.element.contains(event.target)) this._focusFirst()
  }

  /** @private */
  _focusFirst() {
    const [ first ] = this._focusableElements()
    ;(first || this.element).focus()
  }

  /**
   * The modal's focusable elements in tab order, skipping hidden elements and those removed from
   * the tab order through a negative tabindex.
   * @private
   */
  _focusableElements() {
    return Array.from(this.element.querySelectorAll(FOCUSABLE)).filter((element) => {
      return element.tabIndex >= 0 && !element.closest("[inert]") && element.getClientRects().length > 0
    })
  }
}
