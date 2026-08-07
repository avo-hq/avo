import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input']

  connect() {
    // Remove the field from form submission if it's empty
    // This prevents overwriting encrypted values with empty strings
    this.element.closest('form')?.addEventListener('submit', (event) => {
      if (this.hasInputTarget && this.inputTarget.value === '') {
        this.inputTarget.disabled = true
      }
    })
  }
}
