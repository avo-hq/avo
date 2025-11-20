import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "image"]

  connect() {
    console.log("Lightbox controller connected")
  }

  open(event) {
    const imageUrl = event.target.getAttribute("src")
    const imageAlt = event.target.getAttribute("alt") || "Expanded view of the image"

    this.imageTarget.setAttribute("alt", imageAlt)
    this.imageTarget.setAttribute("src", imageUrl)
    this.modalTarget.classList.remove("hidden")
    
    document.body.style.overflow = "hidden"
  }

  close(event) {
    if (event.target === this.modalTarget || event.target.closest('[data-action*="lightbox#close"]')) {
      this.modalTarget.classList.add("hidden")
    }

    document.body.style.overflow = "auto"
  }
}