/* eslint-disable no-alert */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  spinnerMarkup = '<span class="button__spinner"><span class="loading-spinner" aria-hidden="true"></span></span>'

  static values = {
    confirmationMessage: String,
    confirmed: Boolean,
  }

  connect() {
    this.dialog = document.getElementById('turbo-confirm')
    this.dialogCloseHandler = this.handleDialogClose.bind(this)

    this.dialog.addEventListener('close', this.dialogCloseHandler)
  }

  disconnect() {
    this.dialog.removeEventListener('close', this.dialogCloseHandler)
  }

  attemptSubmit() {
    this.applyLoader()
  }

  get button() {
    return this.context.scope.element
  }

  get spinner() {
    return this.button.querySelector('.button__spinner')
  }

  applyLoader() {
    const { button } = this

    if (this.spinner) return

    // Overlay the spinner, never replace the button's contents: WebKit abandons a submit button's activation behaviour
    // when the element the user clicked is removed while the click is still dispatching (AVO-1751).
    button.insertAdjacentHTML('afterbegin', this.spinnerMarkup)
    button.classList.add('button--loading-active')
    button.setAttribute('aria-busy', 'true')
  }

  handleDialogClose() {
    if (this.dialog.returnValue !== 'confirm') {
      this.resetButton()
    }
  }

  resetButton() {
    const { button } = this

    this.spinner?.remove()
    button.classList.remove('button--loading-active')
    button.removeAttribute('aria-busy')
    button.removeAttribute('disabled')
  }
}
