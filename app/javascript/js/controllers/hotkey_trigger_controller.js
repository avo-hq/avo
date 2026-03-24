import { Controller } from '@hotwired/stimulus'

import { eventTargetIsTypingField } from '../keyboard_context'

export default class extends Controller {
  click(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  #shouldIgnore(event) {
    return event.defaultPrevented || eventTargetIsTypingField(event)
  }

  get #isClickable() {
    return getComputedStyle(this.element).pointerEvents !== 'none'
  }
}
