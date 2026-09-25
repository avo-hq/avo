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
    this.handleSubmitHotkey = this.handleSubmitHotkey.bind(this)
    document.addEventListener('keydown', this.handleKeydown)
    // On the modal rather than the document so it runs before @github/hotkey's document listener,
    // which skips events we have already handled (defaultPrevented).
    this.modalTarget.addEventListener('keydown', this.handleSubmitHotkey)
  }

  disconnectModal() {
    document.removeEventListener('keydown', this.handleKeydown)
    this.modalTarget.removeEventListener('keydown', this.handleSubmitHotkey)
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

  // Not left to a `data-hotkey` on the submit button: @github/hotkey ignores keys typed in fields and is
  // installed on turbo:load / turbo:frame-render only, so a modal a Turbo Stream inserts never gets it.
  handleSubmitHotkey(event) {
    if (event.key !== 'Enter' || !(event.metaKey || event.ctrlKey)) return
    if (event.repeat || event.isComposing || event.defaultPrevented) return
    if (window.Avo?.configuration?.hotkeys?.enabled === false) return
    if (!this.isOpen() || !this.isInnermostModalFor(event.target)) return

    const form = this.findForm(event.target)
    if (!form) return

    // Claim the key even when the submitter is disabled: otherwise the browser's implicit
    // submission or a hotkey on the page behind the modal would act on it.
    event.preventDefault()

    const submitter = this.findSubmitter(form)
    if (submitter?.disabled) return

    this.flashHotkeyBadge(submitter)
    form.requestSubmit(submitter)
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

  isInnermostModalFor(element) {
    const identifier = this.identifier
    return element.closest?.(`[data-${identifier}-target~="modal"]`) === this.modalTarget
  }

  // The form being typed in wins; actions and edit-in-modal wrap the modal in their form.
  findForm(target) {
    return target.closest('form')
      ?? this.modalTarget.closest('form')
      ?? this.modalTarget.querySelector('[data-hotkey="Mod+Enter"]')?.form
      ?? this.modalTarget.querySelector('form')
  }

  /**
   * The button a click would use: the one advertising Cmd+Return, else the last submit button in
   * the modal's footer (Avo puts the primary action last), else the form's last submit button.
   */
  findSubmitter(form) {
    const selector = 'button[type="submit"], input[type="submit"]'
    const submitButtons = (root) => Array.from(root?.querySelectorAll(selector) ?? [])
      .filter((button) => button.form === form)

    const inModal = submitButtons(this.modalTarget)

    return inModal.find((button) => button.matches('[data-hotkey="Mod+Enter"]'))
      ?? submitButtons(this.modalTarget.querySelector('.modal__controls')).at(-1)
      ?? inModal.at(-1)
      ?? submitButtons(form).at(-1)
  }

  // Same feedback hotkeyFireHandler gives when @github/hotkey fires the button.
  flashHotkeyBadge(submitter) {
    submitter?.querySelectorAll('kbd').forEach((kbd) => {
      kbd.classList.add('kbd--called')
      kbd.addEventListener('transitionend', () => kbd.classList.remove('kbd--called'), { once: true })
    })
  }

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
