import BaseModalController from './base_modal_controller'

/**
 * Slide-over strategy.
 *
 * Side-anchored UI shell that mirrors the modal lifecycle but uses its own
 * Turbo frame (Avo::SLIDE_OVER_FRAME_ID) and its own body class
 * (`slide-over-open` instead of `modal-open`) so the two surfaces are isolated
 * and can never be open simultaneously.
 *
 * Invariant: never open the slide-over while a modal is open. On connect, if
 * `body.modal-open` is already present, the slide-over removes itself and logs
 * a console warning. The modal controllers enforce the symmetric check.
 */
export default class extends BaseModalController {
  connect() {
    if (document.body.classList.contains('modal-open')) {
      // eslint-disable-next-line no-console
      console.warn('Cannot open slide-over while a modal is open')
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

  // -- body-class isolation -------------------------------------------------

  addModalOpen() {
    document.body.classList.add('slide-over-open')
  }

  removeModalOpen() {
    document.body.classList.remove('slide-over-open')
  }
}
