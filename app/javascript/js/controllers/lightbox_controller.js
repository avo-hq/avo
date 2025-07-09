import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  connect() {
    console.log("Lightbox controller connected")
  }

  open(event) {
    const imageUrl = event.target.getAttribute("src")
    this.imageTarget.setAttribute("src", imageUrl)
    this.modalTarget.classList.remove("hidden")
  }

  close(event) {
    if (event.target === this.modalTarget) {
      this.modalTarget.classList.add("hidden")
    }
  }
}