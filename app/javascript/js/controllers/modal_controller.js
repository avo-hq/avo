import BaseModalController from './base_modal_controller'

/**
 * Inject / destroy strategy.
 *
 * The modal is added to the DOM (usually via Turbo) when it should appear and
 * removed entirely when it is closed. Showing/hiding the popover drives the CSS
 * enter/leave transition; the element is removed once the leave transition ends.
 */
export default class extends BaseModalController {
  connect() {
    this.connectModal()
    this.addModalOpen()
    this.modalTarget.showPopover()
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
    this.removeModalOpen()

    const remove = () => {
      window.clearTimeout(timer)
      this.modalTarget.removeEventListener('transitionend', remove)
      if (this.modalTarget.isConnected) this.modalTarget.remove()
      this.dispatchClose()
    }

    // Remove once the leave transition finishes, with a timeout fallback for
    // reduced-motion (no transition → no `transitionend`).
    const timer = window.setTimeout(remove, this.constructor.TRANSITION_MS + 50)
    this.modalTarget.addEventListener('transitionend', remove)
    this.modalTarget.hidePopover()
  }
}
