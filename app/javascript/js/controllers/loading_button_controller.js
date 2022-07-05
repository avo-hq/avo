/* eslint-disable no-alert */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  spinnerMarkup = `<div class="button-spinner">
  <div class="double-bounce1"></div>
  <div class="double-bounce2"></div>
</div>`;

  static values = {
    confirmationMessage: String,
    confirmed: Boolean,
  }

  attemptSubmit(e) {
    // If the user has to confirm the action
    if (this.confirmationMessageValue) {
      this.confirmAndApply(e)
    } else {
      this.applyLoader()
    }

    return null
  }

  confirmAndApply(e) {
    // Intervene only if not confirmed
    if (!this.confirmedValue) {
      e.preventDefault()

      if (window.confirm(this.confirmationMessageValue)) {
        this.applyLoader()
      }
    }
  }

  get button() {
    return this.context.scope.element
  }

  applyLoader() {
    const { button } = this

    button.style.width = `${button.getBoundingClientRect().width}px`
    button.style.height = `${button.getBoundingClientRect().height}px`
    button.innerHTML = this.spinnerMarkup
    button.classList.add('justify-center')

    setTimeout(() => {
      this.markConfirmed()
      button.click()
      button.setAttribute('disabled', 'disabled')
    }, 1)
  }

  markConfirmed() {
    this.confirmedValue = true
  }

  markUnconfirmed() {
    this.confirmedValue = false
  }
}
