import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="remove"
/**
 * Use this controller to remove html elements by a given selector.
 *
 * Usage:
 * - Add `data-controller="remove" to connect an element and its children to the controller.
 * - Add `data-action` to the trigger element, e.g. `data-action="click->remove#ancestor"`
 * - Add `data-remove-selector="css-selector"` to the trigger element. This determines which element will be removed.
 */
export default class extends Controller {

  connect() {
  }

  parent(event) {
    this.ancestor(event)
  }

  ancestor(event) {
    event.preventDefault()

    const element = event.currentTarget

    const selector = element.dataset.removeSelector
    if (!selector) {
      console.error("Please add `data-remove-selector='css-selector'` to the data-action element.")
      return
    }

    const ancestor = element.closest(selector)
    if (!ancestor) {
      console.error(`No parent element matching the selector "${selector}" was found`)
      return
    }

    ancestor.remove()
  }
}
