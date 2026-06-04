import { Controller } from '@hotwired/stimulus'

/**
 * Shared behaviour for both modal strategies (destroy & toggle).
 * Not registered with Stimulus directly — subclasses are.
 */
export default class extends Controller {
  static targets = ['modal', 'backdrop']

  // Keep in sync with the --modal-transition-duration CSS variable.
  static TRANSITION_MS = 90

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
    if (event.key === 'Escape' && this.isOpen() && this.closeModalOnBackdropClickValue) {
      this.closeModal()
    }
  }

  /** Backdrop click action — wired via data-action="click->…#close" */
  close(event) {
    if (event.target === this.backdropTarget && !this.closeModalOnBackdropClickValue) return

    this.closeModal()
  }

  // -- helpers --------------------------------------------------------------

  addModalOpen() {
    document.body.classList.add('modal-open')
  }

  removeModalOpen() {
    document.body.classList.remove('modal-open')
  }

  // -- enter / leave transitions --------------------------------------------

  /**
   * Reveal the card with the scale-in transition. The element must already be
   * visible (in the DOM / not `hidden`) so the closed styles paint first; the
   * double rAF guarantees that initial frame before we flip to the open state.
   */
  reveal() {
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.modalTarget.classList.add('modal--open')
      })
    })
  }

  /**
   * Play the leave transition, then run `onComplete` (remove or hide the
   * element). Falls back to a timeout in case `transitionend` never fires.
   */
  conceal(onComplete) {
    this.modalTarget.classList.remove('modal--open')
    window.setTimeout(onComplete, this.constructor.TRANSITION_MS)
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
