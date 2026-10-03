import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown-keyboard"
/**
 * This Stimulus controller, `DropdownKeyboardController`, adds keyboard support
 * to a Flowbite dropdown. Flowbite opens and closes the menu when the trigger
 * is clicked; this controller handles everything else:
 *
 * - Moves focus into the menu when it opens, to the current item if there is one.
 * - ArrowDown/ArrowUp on the trigger open the menu, or move focus into it.
 * - ArrowDown/ArrowUp/Home/End move between the menu items.
 * - Escape closes the menu and returns focus to the trigger.
 * - Closes the menu when focus leaves the dropdown.
 * - Closes the menu and returns focus to the trigger when a form in the menu
 *   is submitted, so focus survives a Turbo Stream morph of the dropdown.
 *
 * Usage:
 * - Add `data-controller="dropdown-keyboard"` to an element containing the trigger and the menu.
 * - Add `data-dropdown-keyboard-target="trigger"` to the element with `data-dropdown-toggle`.
 * - Add `data-dropdown-keyboard-target="menu"` to the menu element.
 * - Add `data-dropdown-keyboard-target="item"` to each focusable menu item.
 * - Mark the current item with `aria-current="true"` to focus it first.
 *
 * Targets:
 * - `trigger`: the element that toggles the menu.
 * - `menu`: the menu element, hidden through the `hidden` class while closed.
 * - `item`: the focusable items in the menu.
 */
export default class extends Controller {
  static targets = [ "trigger", "menu", "item" ]

  connect() {
    this.triggerTarget.setAttribute("aria-expanded", this._isOpen())
  }

  /**
   * Called after the trigger was clicked. Flowbite toggles the menu in its own
   * click handler, so the new state is checked once that has run.
   */
  toggled() {
    setTimeout(() => {
      const open = this._isOpen()
      this.triggerTarget.setAttribute("aria-expanded", open)
      if (open) this._focusItem(this._currentItemIndex())
    })
  }

  /**
   * Handles the keyboard within the dropdown. On the trigger, the arrow keys
   * open the menu or move focus into it. In the menu, they move between the
   * items. Escape closes the menu and returns focus to the trigger.
   * @param {KeyboardEvent} event
   */
  keydown(event) {
    if (event.key === "Escape") {
      if (!this._isOpen()) return

      this._close()
      this.triggerTarget.focus()
    } else if (!["ArrowDown", "ArrowUp", "Home", "End"].includes(event.key)) {
      return
    } else if (!this._isOpen()) {
      if (event.target !== this.triggerTarget) return

      this.triggerTarget.click()
    } else if (!this.menuTarget.contains(event.target)) {
      this._focusItem(this._currentItemIndex())
    } else {
      this._focusItem(this._nextItemIndex(event.key))
    }
    event.preventDefault()
  }

  /**
   * Closes the menu when focus moves outside of the dropdown.
   * @param {FocusEvent} event
   */
  focusout(event) {
    if (event.relatedTarget && !this.element.contains(event.relatedTarget)) this._close()
  }

  /**
   * Closes the menu and returns focus to the trigger once a form is submitted.
   */
  submitted() {
    this._close()
    this.triggerTarget.focus()
  }

  /** @private */
  _isOpen() {
    return !this.menuTarget.classList.contains("hidden")
  }

  /** @private */
  _close() {
    if (this._isOpen()) this.triggerTarget.click()
  }

  /** @private */
  _currentItemIndex() {
    const index = this.itemTargets.findIndex((item) => item.getAttribute("aria-current") === "true")
    return Math.max(index, 0)
  }

  /** @private */
  _nextItemIndex(key) {
    const index = this.itemTargets.indexOf(document.activeElement)
    const last = this.itemTargets.length - 1

    switch (key) {
      case "ArrowDown": return index < last ? index + 1 : 0
      case "ArrowUp": return index > 0 ? index - 1 : last
      case "Home": return 0
      case "End": return last
    }
  }

  /** @private */
  _focusItem(index) {
    this.itemTargets[index]?.focus()
  }
}
