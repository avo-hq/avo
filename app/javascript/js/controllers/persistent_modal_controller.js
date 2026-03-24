import BaseModalController from './base_modal_controller'

/**
 * Persistent / show-hide strategy.
 *
 * The modal lives in the DOM at all times. It starts with the `hidden`
 * attribute and is revealed / hidden by toggling that attribute.
 */
export default class extends BaseModalController {
  connect() {
    this.connectModal()

    this.handleOpen = this.openModal.bind(this)
    this.handleToggle = this.toggleModal.bind(this)
    document.addEventListener('persistent-modal:open', this.handleOpen)
    document.addEventListener('persistent-modal:toggle', this.handleToggle)
  }

  disconnect() {
    this.disconnectModal()
    document.removeEventListener('persistent-modal:open', this.handleOpen)
    document.removeEventListener('persistent-modal:toggle', this.handleToggle)
  }

  // -- strategy implementation ----------------------------------------------

  isOpen() {
    return !this.modalTarget.hasAttribute('hidden')
  }

  closeModal() {
    this.modalTarget.setAttribute('hidden', '')
    this.removeModalOpen()
    this.dispatchClose()
  }

  openModal() {
    this.modalTarget.removeAttribute('hidden')
    this.addModalOpen()
  }

  toggleModal() {
    if (this.isOpen()) {
      this.closeModal()
    } else {
      this.openModal()
    }
  }
}
