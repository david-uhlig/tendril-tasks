import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fade-out-and-remove"
export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.element.classList.add("animate-pulse");
    }, 3000);

    setTimeout(() => {
      this.element.remove();
    }, 5000);
  }
}
