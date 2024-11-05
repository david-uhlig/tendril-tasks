import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-focus"
/**
 * This Stimulus controller, `AutoFocusController`, automatically sets focus on a specified element
 * when it becomes visible in the viewport. If the element goes out of view, it returns focus to
 * the element that was previously focused.
 *
 * Usage:
 * - Add `data-controller="auto-focus"` to the container element.
 * - Add `data-auto-focus-target="focusHere"` to the element that should receive focus.
 */
export default class extends Controller {
  static targets = [ "focusHere" ]

  connect() {
    if (!this.hasFocusHereTarget) {
      console.error('Add `data-auto-focus-target="focusHere"` to the element that shall receive focus.')
      return
    }

    // Stores the element that had focus before this controller activates
    this.previousFocusedElement = null

    // Set up an IntersectionObserver to monitor the element's visibility
    this.observer = new IntersectionObserver(
        (entries) => {
          for (const entry of entries) {
            if (entry.isIntersecting) {
              this._giveFocus()
            } else {
              this._returnFocus()
            }
          }
        },
        { threshold: 0.1 } // Customize as needed, e.g., 0.1 for 10% visibility
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    // Clean up the observer when the controller disconnects
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  /**
   * Sets focus on the specified target element and saves the currently focused element.
   * @private
   */
  _giveFocus() {
    // Save the currently focused element, if it exists
    this.previousFocusedElement = document.activeElement

    // Brief delay for smoother focus shifts, improving accessibility
    requestAnimationFrame(() => this.focusHereTarget.focus())
  }

  /**
   * Returns focus to the previously focused element when the observed element is no longer visible.
   * @private
   */
  _returnFocus() {
    // Return focus only if the previous element is still in the DOM
    if (this.previousFocusedElement && document.contains(this.previousFocusedElement)) {
      this.previousFocusedElement.focus()
      this.previousFocusedElement = null
    }
  }
}
