import BaseModalController from './base_modal_controller'

/**
 * Inject / destroy strategy.
 *
 * The modal is added to the DOM (usually via Turbo) when it should appear
 * and removed entirely when it is closed.
 */
export default class extends BaseModalController {
  connect() {
    this.connectModal()
    this.addModalOpen()
  }

  disconnect() {
    this.disconnectModal()
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
