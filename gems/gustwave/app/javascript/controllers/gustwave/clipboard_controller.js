import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gustwave--clipboard"
/**
 * This Stimulus controller, `ClipboardController`, shows the copied state of a Gustwave::Clipboard
 * button, and of its tooltip, after the text has been copied, and returns to the default state
 * after `reset-after` milliseconds.
 *
 * - Flowbite's JavaScript copies the text on its own click listener. This controller listens to the
 *   click too, instead of Flowbite's `updateOnCopyCallback`, because `initFlowbite()` recreates the
 *   instances with `override: true` on every Turbo load, which drops callbacks.
 * - The tooltip is rendered outside the button, so its states are found by id, not as targets.
 *
 * Usage:
 * - Added by Gustwave::Clipboard. The tooltip's id is its `tooltip-id` value, when it renders a tooltip.
 */
export default class extends Controller {
  static targets = ["message", "copiedMessage"]
  static values = { resetAfter: { type: Number, default: 2000 }, tooltipId: String }

  disconnect() {
    clearTimeout(this.timer)
  }

  /**
   * Shows the copied state and the tooltip, then schedules the reset. A running reset is replaced,
   * so repeated copies restart the timer. A `reset-after` of zero or less keeps the copied state.
   */
  copied() {
    clearTimeout(this.timer)
    this._setCopied(true)

    if (this.resetAfterValue > 0) {
      this.timer = setTimeout(() => this.reset(), this.resetAfterValue)
    }
  }

  /**
   * Shows the default state again and hides the tooltip.
   */
  reset() {
    clearTimeout(this.timer)
    this._setCopied(false)
  }

  /**
   * @param {boolean} copied
   * @private
   */
  _setCopied(copied) {
    this._setStates(this.messageTargets, this.copiedMessageTargets, copied)

    const tooltip = this.tooltipElement
    if (tooltip) {
      this._setStates(this._tooltipStates(tooltip, "message"), this._tooltipStates(tooltip, "copiedMessage"), copied)
      const instance = window.FlowbiteInstances?.getInstance("Tooltip", this.tooltipIdValue)
      copied ? instance?.show() : instance?.hide()
    }
  }

  /**
   * @param {Element[]|NodeList} messages the default state's elements
   * @param {Element[]|NodeList} copiedMessages the copied state's elements
   * @param {boolean} copied
   * @private
   */
  _setStates(messages, copiedMessages, copied) {
    messages.forEach((element) => { element.hidden = copied })
    copiedMessages.forEach((element) => { element.hidden = !copied })
  }

  /**
   * @param {Element} tooltip
   * @param {string} name the target name, `message` or `copiedMessage`
   * @returns {NodeList}
   * @private
   */
  _tooltipStates(tooltip, name) {
    return tooltip.querySelectorAll(`[data-gustwave--clipboard-target="${name}"]`)
  }

  /**
   * @returns {Element|null} the tooltip the button points to, if it renders one
   * @private
   */
  get tooltipElement() {
    return this.hasTooltipIdValue ? document.getElementById(this.tooltipIdValue) : null
  }
}
