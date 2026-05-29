import BaseModalController from './base_modal_controller'

/**
 * Inject / destroy strategy.
 *
 * The modal is added to the DOM (usually via Turbo) when it should appear
 * and removed entirely when it is closed.
 */
export default class extends BaseModalController {
  connect() {
    if (document.body.classList.contains('slide-over-open')) {
      // eslint-disable-next-line no-console
      console.warn('Cannot open modal while a slide-over is open')
      this.modalTarget.remove()
      return
    }

    this.connectModal()
    this.addModalOpen()
    this.modalTarget.focus()
  }

  disconnect() {
    this.disconnectModal()
    this.removeModalOpen()
  }

  // -- strategy implementation ----------------------------------------------

  isOpen() {
    return true // if the element is in the DOM it's open
  }

  closeModal() {
    this.modalTarget.remove()
    this.removeModalOpen()
    this.dispatchClose()
  }
}
