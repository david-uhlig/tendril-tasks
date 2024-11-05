import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list-mover"
export default class extends Controller {
  toggle(event) {
    const checkbox = event.target
    const li = event.target.closest("li") // Get the <li> that contains the checkbox

    if (checkbox.checked) {
      const coordinatorsList = document.getElementById("coordinators")
      coordinatorsList.appendChild(li)
    } else {
      const candidatesList = document.getElementById("candidates")
      candidatesList.appendChild(li)
    }
  }
}
