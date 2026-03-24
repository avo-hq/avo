import { Controller } from '@hotwired/stimulus'

/**
 * Shared behaviour for both modal strategies (destroy & toggle).
 * Not registered with Stimulus directly — subclasses are.
 */
export default class extends Controller {
  static targets = ['modal', 'backdrop']

  static values = {
    closeModalOnBackdropClick: { type: Boolean, default: true },
  }

  // -- lifecycle ------------------------------------------------------------

  connectModal() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.handleKeydown)
  }

  disconnectModal() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  // -- shared actions -------------------------------------------------------

  handleKeydown(event) {
    if (event.key === 'Escape' && this.isOpen()) {
      this.closeModal()
    }
  }

  /** Backdrop click action — wired via data-action="click->…#close" */
  close(event) {
    if (event.target === this.backdropTarget) return

    this.closeModal()
  }

  // -- helpers --------------------------------------------------------------

  addModalOpen() {
    document.body.classList.add('modal-open')
  }

  removeModalOpen() {
    document.body.classList.remove('modal-open')
  }

  dispatchClose() {
    document.dispatchEvent(new Event('modal-controller:close'))
  }

  // -- subclass contract (override in each strategy) ------------------------

  /** @abstract */
  closeModal() {
    throw new Error('Subclass must implement closeModal()')
  }

  /** @abstract */
  isOpen() {
    throw new Error('Subclass must implement isOpen()')
  }
}
