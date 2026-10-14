import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal-form"
/**
 * This Stimulus controller, `ModalFormController`, hides a Flowbite modal once a form inside it was
 * submitted successfully. When the submission fails, e.g. with 422 Unprocessable Content, the modal
 * stays open so the response can show the errors.
 *
 * Usage:
 * - Add `data-controller="modal-form"` and
 *   `data-action="turbo:submit-end->modal-form#hideOnSuccess"` to the modal element.
 */
export default class extends Controller {
  /**
   * @param {CustomEvent} event the `turbo:submit-end` event of a form inside the modal
   */
  hideOnSuccess(event) {
    if (!event.detail.success) return

    window.FlowbiteInstances?.getInstance("Modal", this.element.id)?.hide()
  }
}
