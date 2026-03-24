import { Controller } from '@hotwired/stimulus'

import { eventTargetIsTypingField } from '../keyboard_context'

export default class extends Controller {
  static targets = ['panel']

  #handleKeydown = (event) => {
    if (event.defaultPrevented || event.repeat) return

    if (event.key === 'Escape') {
      this.panelTarget.setAttribute('hidden', '')
      return
    }

    if (eventTargetIsTypingField(event)) return

    if (this.#isShortcutsKey(event)) {
      event.preventDefault()
      this.toggle()
    }
  }

  connect() {
    document.addEventListener('keydown', this.#handleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.#handleKeydown)
  }

  /** Click target (navbar): show / hide the shortcuts panel */
  toggle() {
    this.panelTarget.toggleAttribute('hidden')
  }

  close() {
    this.panelTarget.setAttribute('hidden', '')
  }

  #isShortcutsKey(event) {
    // US: Shift+/ → "?". Some layouts/browsers only expose Slash + shift.
    return (
      event.key === '?'
      || (event.shiftKey && event.code === 'Slash')
    )
  }
}
