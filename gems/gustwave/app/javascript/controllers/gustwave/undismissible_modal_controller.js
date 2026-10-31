import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gustwave--undismissible-modal"
/**
 * This Stimulus controller, `UndismissibleModalController`, keeps Escape from closing a modal that
 * is rendered with `dismissible: false`.
 *
 * - It exists because Flowbite's `closable` option is never read from markup, and `initFlowbite()`
 *   recreates every modal with `override: true` on each Turbo load, which would discard a
 *   `closable` set in JavaScript.
 * - It listens on `document` in the capture phase, which runs before Flowbite's own capture-phase
 *   Escape listener on `document.body`.
 * - Limitation: while the modal is shown, Escape doesn't reach the modal's content.
 *
 * Usage:
 * - Added by Gustwave::Modal when `dismissible: false`.
 */
export default class extends Controller {
  connect() {
    this.keydown = this._keydown.bind(this)
    document.addEventListener("keydown", this.keydown, true)
  }

  disconnect() {
    document.removeEventListener("keydown", this.keydown, true)
  }

  /**
   * Stops Escape from reaching Flowbite while the modal is shown. Only stopPropagation is called,
   * not stopImmediatePropagation, so the focus trap's keydown listener on `document` still runs.
   * The browser's default behaviour for Escape is left alone.
   * @param {KeyboardEvent} event
   * @private
   */
  _keydown(event) {
    if (event.key === "Escape" && !this.element.classList.contains("hidden")) {
      event.stopPropagation()
    }
  }
}
