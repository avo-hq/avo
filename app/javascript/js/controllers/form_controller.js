import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="form"
export default class extends Controller {
  submit(event) {
    // return if event.key is undefined preventing the form submit on autocomplete event
    if (!event.key) return

    this.element.requestSubmit()
  }
}
