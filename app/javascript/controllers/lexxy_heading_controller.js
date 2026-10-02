import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lexxy-heading"
/**
 * This Stimulus controller, `LexxyHeadingController`, turns the heading buttons of a custom
 * `<lexxy-toolbar>` into toggles. Lexxy only tracks the active heading in its own heading
 * dropdown, so this controller marks the button of the heading under the cursor as pressed.
 * Clicking a pressed button turns the heading back into a paragraph.
 *
 * Usage:
 * - Add `data-controller="lexxy-heading"` to the `<lexxy-toolbar>` element.
 * - Add `data-lexxy-heading-target="button"` to each heading button. The button's
 *   `data-payload` holds the heading tag, e.g. `h2`.
 */
export default class extends Controller {
  static targets = [ "button" ]

  async connect() {
    this.update = this._update.bind(this)
    await customElements.whenDefined("lexxy-toolbar")
    this.editorElement = await this.element.getEditorElement()
    if (!this.editorElement || !this.element.isConnected) return

    document.addEventListener("selectionchange", this.update)
    this.editorElement.addEventListener("lexxy:change", this.update)
    this._update()
  }

  disconnect() {
    document.removeEventListener("selectionchange", this.update)
    this.editorElement?.removeEventListener("lexxy:change", this.update)
  }

  _update() {
    const activeTag = this._activeHeadingTag()

    this.buttonTargets.forEach((button) => {
      if (button.disabled) return

      const pressed = button.dataset.payload === activeTag
      button.ariaPressed = pressed
      button.dataset.command = pressed ? "setFormatParagraph" : "applyHeadingFormat"
    })
  }

  _activeHeadingTag() {
    const node = document.getSelection()?.anchorNode
    const element = node?.nodeType === Node.TEXT_NODE ? node.parentElement : node
    if (!element || !this.editorElement.contains(element)) return null

    return element.closest("h1, h2, h3, h4, h5, h6")?.tagName.toLowerCase() ?? null
  }
}
