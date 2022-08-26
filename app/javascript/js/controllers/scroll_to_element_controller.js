import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    location: String,
  }

  connect() {
    setTimeout(() => {
      this.targetElement.scrollIntoView()
    }, 150)
    // this.scrollIntoViewAfterLoaded(this.targetElement)
    this.element.remove()
  }

  get targetElement() {
    return document.getElementById(this.locationValue)
  }

  scrollIntoViewAfterLoaded(element) {

  }
}
