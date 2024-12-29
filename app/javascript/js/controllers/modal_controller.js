import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = ['modal', 'backdrop']

  static values = {
    closeModalOnBackdropClick: true,
  }

  close(event) {
    if (event.target === this.backdropTarget && !this.closeModalOnBackdropClickValue) return

    this.closeModal()
  }

  // May be invoked by the other controllers
  closeModal() {
    this.modalTarget.remove()

    document.dispatchEvent(new Event('modal-controller:close'))
  }
}
