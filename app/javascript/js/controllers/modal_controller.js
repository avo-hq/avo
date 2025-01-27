import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal', 'backdrop']

  static values = {
    closeModalOnBackdropClick: true,
  }

  close() {
    if (event.target === this.backdropTarget && !this.closeModalOnBackdropClickValue) return

    this.modalTarget.remove()

    document.dispatchEvent(new Event('actions-modal:close'))
  }
}
