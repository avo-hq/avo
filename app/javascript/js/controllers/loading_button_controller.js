/* eslint-disable no-alert */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  spinnerMarkup = `<div class="button-spinner">
  <div class="double-bounce1"></div>
  <div class="double-bounce2"></div>
</div>`;

  confirmed = false

  connect() {
    this.context.scope.element.addEventListener('click', (e) => {
      // If the user has to confirm the action
      if (this.confirmationMessage) {
        // Intervene only if not confirmed
        if (!this.confirmed) {
          e.preventDefault()
          if (window.confirm(this.confirmationMessage)) {
            this.applyLoader()
          }
        }
      } else {
        this.applyLoader()
      }
    })
  }

  get button() {
    return this.context.scope.element
  }

  get confirmationMessage() {
    return this.context.scope.element.getAttribute('data-avo-confirm')
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
    this.confirmed = true
  }

  markUnconfirmed() {
    this.confirmed = false
  }
}
