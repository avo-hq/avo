import { Controller } from '@hotwired/stimulus'

/**
 * Shared behaviour for both modal strategies (destroy & toggle).
 * Not registered with Stimulus directly — subclasses are.
 *
 * The modal is a native popover (`popover="manual"`) rendered in the top layer.
 * Enter/leave animations are pure CSS (`@starting-style` + `transition-behavior:
 * allow-discrete`); this controller only opens/closes the popover and manages the
 * `modal-open` body state.
 */
export default class extends Controller {
  static targets = ['modal', 'card']

  // Fallback for removing an ephemeral modal when no leave transition fires
  // (e.g. prefers-reduced-motion). Keep >= the --modal-transition-duration CSS var.
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
    if (event.key !== 'Escape' || !this.isOpen()) return

    // Escape dismisses, or — when backdrop/Escape closing is disabled — nods "no".
    if (this.closeModalOnBackdropClickValue) {
      this.closeModal()
    } else {
      this.nudge()
    }
  }

  /** Explicit close — wired to buttons (Cancel, the X, etc.). Always closes. */
  close() {
    this.closeModal()
  }

  /**
   * Backdrop click — wired via data-action="click->…#closeOnBackdrop" on the
   * modal element. The native `::backdrop` sits behind the modal, so a click on
   * the empty centering area lands on the modal element itself (event.target ===
   * the modal). Clicks bubbling up from buttons/card content are ignored here so
   * they don't double-fire alongside their own #close action.
   */
  closeOnBackdrop(event) {
    if (event.target !== this.modalTarget) return

    // When dismissal is disabled, shake the card to signal "no" instead of closing.
    if (!this.closeModalOnBackdropClickValue) {
      this.nudge()
      return
    }

    this.closeModal()
  }

  /**
   * Head-shake "no" on the card — used when the modal refuses to dismiss. The
   * remove + reflow + re-add lets the animation restart on rapid repeat attempts.
   */
  nudge() {
    if (!this.hasCardTarget) return

    const card = this.cardTarget
    card.classList.remove('modal__card--nudge')
    void card.offsetWidth // force reflow so the animation replays
    card.classList.add('modal__card--nudge')
    card.addEventListener('animationend', () => card.classList.remove('modal__card--nudge'), { once: true })
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
