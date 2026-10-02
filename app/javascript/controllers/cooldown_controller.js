import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cooldown"
/**
 * This Stimulus controller, `CooldownController`, disables a (destructive) button for a few seconds
 * whenever its modal is shown, to prevent accidental clicks. A countdown is appended to the label
 * while the button is disabled.
 *
 * The controller watches the `hidden` class of its element, which Flowbite toggles when showing or
 * hiding a modal.
 *
 * Usage:
 * - Add `data-controller="cooldown"` to the modal element.
 * - Add `data-cooldown-seconds-value="3"` to configure the duration (0 disables the cooldown).
 * - Add `data-cooldown-target="button"` to the button that shall be disabled.
 * - Add `data-cooldown-target="label"` to the element holding the button text (optional).
 */
export default class extends Controller {
  static targets = [ "button", "label" ]
  static values = { seconds: { type: Number, default: 3 } }

  connect() {
    if (!this.hasButtonTarget) {
      console.error('Add `data-cooldown-target="button"` to the button that shall be disabled.')
      return
    }

    this.originalLabel = this.hasLabelTarget ? this.labelTarget.textContent : null
    this.preventSubmit = this._preventSubmit.bind(this)
    this.buttonTarget.form?.addEventListener("submit", this.preventSubmit)

    this.visible = false
    this.observer = new MutationObserver(() => this._visibilityChanged())
    this.observer.observe(this.element, { attributes: true, attributeFilter: [ "class" ] })
    this._visibilityChanged()
  }

  disconnect() {
    this.observer?.disconnect()
    this.buttonTarget.form?.removeEventListener("submit", this.preventSubmit)
    this._finish()
  }

  /**
   * Starts the cooldown when the modal becomes visible and cancels it when the modal is hidden.
   * @private
   */
  _visibilityChanged() {
    const visible = !this.element.classList.contains("hidden")
    if (visible === this.visible) return

    this.visible = visible
    visible ? this._start() : this._finish()
  }

  /**
   * @private
   */
  _start() {
    this._finish()
    if (this.secondsValue <= 0) return

    this.remaining = this.secondsValue
    this.coolingDown = true
    this.buttonTarget.disabled = true
    this.buttonTarget.setAttribute("aria-disabled", "true")
    this._render()

    this.timer = setInterval(() => {
      this.remaining -= 1
      this.remaining > 0 ? this._render() : this._finish()
    }, 1000)
  }

  /**
   * Re-enables the button and restores its original label.
   * @private
   */
  _finish() {
    clearInterval(this.timer)
    this.timer = null
    this.coolingDown = false
    this.buttonTarget.disabled = false
    this.buttonTarget.removeAttribute("aria-disabled")
    if (this.hasLabelTarget) this.labelTarget.textContent = this.originalLabel
  }

  /**
   * @private
   */
  _render() {
    if (this.hasLabelTarget) this.labelTarget.textContent = `${this.originalLabel} (${this.remaining})`
  }

  /**
   * Guards against submissions while the cooldown is running, e.g. by pressing Enter.
   * @private
   */
  _preventSubmit(event) {
    if (this.coolingDown) event.preventDefault()
  }
}
