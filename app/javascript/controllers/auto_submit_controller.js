import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-submit"
/**
 * This Stimulus controller, `AutoSubmitController`, automatically submits a form
 * using the designated submit button, with options for immediate or delayed submission.
 * It’s typically used for cases where forms should auto-submit on certain events,
 * such as typing or changing fields.
 *
 * Usage:
 * - Add `data-controller="auto-submit"` to the form or form container element.
 * - Add `data-auto-submit-target="submit"` to the submit button used for submission.
 *
 * Targets:
 * - `submit`: the submit button element that will be triggered for form submission.
 *
 * Values:
 * - `delay`: the delay in ms before the form is sent with the `delayed` method, default: 500 ms.
 */
export default class extends Controller {
  static targets = [ "submit" ]
  static values = {
    delay: Number
  }

  /**
   * Called when the controller is connected to the DOM.
   * Checks if the required `submit` target exists and identifies
   * the form element containing the controller.
   */
  connect() {
    if (!this.hasSubmitTarget) {
      console.error('Add `data-auto-submit-target="submit"` to the submit button that shall be used to auto-submit this form.')
      return
    }

    this.delay = 500
    if (this.hasDelayValue) {
      this.delay = this.delayValue
    }

    // Cache references to the submit button and form element for reuse.
    this.submitter = this.submitTarget
    this.formElement = this.submitter.closest("form")
  }

  /**
   * Called when the controller is disconnected from the DOM.
   * Clears any pending timeouts to prevent accidental submits after disconnection.
   */
  disconnect() {
    clearTimeout(this.timeout)
  }

  /**
   * Submits the form immediately on the associated event.
   * @param {Event} event - The event triggering the immediate submission.
   */
  immediately(event) {
    this._requestSubmit()
  }

  /**
   * Delays form submission to allow for additional user input.
   * Resets the timeout if called multiple times to ensure only the final event
   * triggers the submission after a delay.
   *
   * @param {Event} event - The event triggering the delayed submission.
   */
  delayed(event) {
    // Clear any existing timeout to prevent multiple submissions
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this._requestSubmit()
    }, this.delay) // Delay in milliseconds
  }

  /**
   * Helper function that triggers form submission using the designated submit button.
   * Uses `requestSubmit`, which ensures that any form validation constraints are respected.
   * This is particularly useful for modern browsers.
   *
   * @private
   */
  _requestSubmit() {
    this.formElement.requestSubmit(this.submitter)
  }
}
