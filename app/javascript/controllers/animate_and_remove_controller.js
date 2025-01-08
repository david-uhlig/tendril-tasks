import { Controller } from "@hotwired/stimulus"

/**
 * Manages element animation and removal with timeouts.
 *
 * Connects to: `data-controller="animate-and-remove"`
 *
 * ### Values:
 * - `animateAfter` (Number): Delay in milliseconds before applying the animation class. Default: 5000.
 * - `animateClass` (String): The CSS class to apply for animation. Default: "animate-pulse".
 * - `removeAfter` (Number): Delay in milliseconds before removing the element. Default: 7000.
 *
 * ### Methods:
 * - `connect()`: Initializes timeouts for animation and removal.
 * - `disconnect()`: Cleans up timeouts when the controller is disconnected.
 * - `pause()`: Clears timeouts temporarily.
 * - `continue()`: Re-establishes timeouts.
 */
export default class extends Controller {
  static values = {
    animateAfter: { type: Number, default: 5000 }, // Time in ms before the animation classes are attached
    animateClass: { type: String, default: "animate-pulse" }, // CSS classes to attach to start an animation
    removeAfter: { type: Number, default: 7000 } // Time in ms before element removal
  }

  connect() {
    this.setTimeouts()
  }

  disconnect() {
    this.clearTimeouts()
  }

  /**
   * Pauses both animation and removal timeouts.
   *
   * Can be used to give the user more time for interacting with an element
   * before, e.g. through a mouseover action: `mouseover->animate-and-remove#pause`
   */
  pause() {
    this.clearTimeouts()
  }

  /**
   * Restart the animation and removal timeouts.
   *
   * Useful to restart the timers after a `pause()`, e.g. through a mouseout
   * action: `mouseout->animate-and-remove#continue`
   */
  continue() {
    this.setTimeouts()
  }

  setTimeouts() {
    this.setAnimationTimeout()
    this.setRemoveTimeout()
  }

  clearTimeouts() {
    this.element.classList.remove(this.animateClassValue)
    clearTimeout(this.animationTimeout)
    clearTimeout(this.removeTimeout)
  }

  setAnimationTimeout() {
    if (!(this.animateAfterValue > 0)) return

    this.animationTimeout = setTimeout(() => {
      this.element.classList.add(this.animateClassValue)
    }, this.animateAfterValue)
  }

  setRemoveTimeout() {
    if (!(this.removeAfterValue > 0)) return

    this.removeTimeout = setTimeout(() => {
      this.element.remove()
    }, this.removeAfterValue)
  }
}
