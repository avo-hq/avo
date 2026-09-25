import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="form"
export default class extends Controller {
  submit(event) {
    // return if event.key is undefined preventing the form submit on autocomplete event
    if (!event.key) return
    // A modal inside this form already submitted it (see base_modal_controller#handleSubmitHotkey).
    if (event.defaultPrevented) return

    // Without this the browser's implicit submission on Return sends the form a second time.
    event.preventDefault()
    this.element.requestSubmit()
  }
}
