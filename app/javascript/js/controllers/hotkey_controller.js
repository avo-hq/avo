import { Controller } from '@hotwired/stimulus'

import { eventTargetIsTypingField } from '../keyboard_context'

export default class extends Controller {
  #handleKeydown = (event) => {
    if (event.defaultPrevented || event.repeat) return

    if (eventTargetIsTypingField(event)) {
      if (event.key === 'Escape') event.target.blur()

      return
    }

    if (this.#isShortcutsKey(event)) {
      event.preventDefault()
      document.dispatchEvent(new Event('persistent-modal:toggle'))
    }
  }

  connect() {
    document.addEventListener('keydown', this.#handleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.#handleKeydown)
  }

  #isShortcutsKey(event) {
    // US: Shift+/ → "?". Some layouts/browsers only expose Slash + shift.
    return (event.key === '?' || (event.shiftKey && event.code === 'Slash'))
  }
}
