import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["previewContainer", "removeIcon"];

  preview() {
    this.removeIconTarget.style.display = "block";
  }

  remove(event) {
    event.preventDefault();
    const fileInput = this.previewContainerTarget.querySelector('input[type="file"]');
    fileInput.value = "";
    this.removeIconTarget.style.display = "none";
  }
}
