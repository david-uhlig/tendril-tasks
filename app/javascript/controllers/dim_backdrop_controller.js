import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dim-backdrop"
export default class extends Controller {
  connect() {
    // Set up an IntersectionObserver to monitor the element's visibility
    this.observer = new IntersectionObserver(
        (entries) => {
          for (const entry of entries) {
            if (entry.isIntersecting) {
              this._dimBackdrop()
            } else {
              this._restoreBackdrop()
            }
          }
        },
        { threshold: 0.1 } // Customize as needed, e.g., 0.1 for 10% visibility
    )

    this.observer.observe(this.element)
    this.backdropId = "dimmed-backdrop"
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  _dimBackdrop() {
    document.body.insertAdjacentHTML('beforeend', `<div id="${this.backdropId}" class="bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-40"></div>`)
    this._removeClone()
  }

  _restoreBackdrop() {
    const backdropElement = document.getElementById(this.backdropId)
    if (backdropElement) {
      backdropElement.remove()
    }
  }

  _removeClone() {
    const backdropElement = document.getElementById(this.backdropId)

    if (backdropElement) {
      const sibling = Array.from(backdropElement.parentNode.children).find(
          (sibling) =>
              sibling !== backdropElement &&
              sibling.classList.length === backdropElement.classList.length &&
              [...sibling.classList].every(cls => backdropElement.classList.contains(cls))
      )

      if (sibling) {
        sibling.remove()
      }
    }
  }

}
