import { Controller } from '@hotwired/stimulus'

// Display-only reveal field: keeps the plaintext out of the input until the
// user clicks the eye toggle. The payload is Base64-encoded in a Stimulus
// value so a casual DOM inspection does not show the secret clearly.
export default class extends Controller {
  static targets = ['input', 'button', 'icon']

  static values = {
    payload: String,
    mask: String,
  }

  connect() {
    this.revealed = false
  }

  toggle() {
    if (this.revealed) {
      this.hide()
    } else {
      this.reveal()
    }
  }

  reveal() {
    this.inputTarget.value = this.decode(this.payloadValue)
    this.inputTarget.type = 'text'
    this.revealed = true
    this.syncUi()
  }

  hide() {
    this.inputTarget.type = 'password'
    this.inputTarget.value = this.maskValue
    this.revealed = false
    this.syncUi()
  }

  syncUi() {
    this.iconTargets.forEach((icon) => icon.classList.toggle('hidden'))

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute('aria-pressed', this.revealed ? 'true' : 'false')
      this.buttonTarget.setAttribute(
        'aria-label',
        this.revealed ? this.hideLabel : this.showLabel,
      )
    }
  }

  decode(encoded) {
    if (!encoded) return ''

    const binary = atob(encoded)
    const bytes = Uint8Array.from(binary, (char) => char.charCodeAt(0))

    return new TextDecoder().decode(bytes)
  }

  get showLabel() {
    return this.buttonTarget.dataset.showLabel || 'Show content'
  }

  get hideLabel() {
    return this.buttonTarget.dataset.hideLabel || 'Hide content'
  }
}
