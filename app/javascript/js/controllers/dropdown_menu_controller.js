import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['menu']

  static values = {
    // One may want to have elements that are exempt from triggering the click outside event
    exemptionContainers: Array,
    logger: Boolean,
  }

  get exemptionContainerTargets() {
    return this.exemptionContainersValue.map((selector) => document.querySelector(selector)).filter(Boolean)
  }

  get isOpen() {
    return this.menuTarget.hasAttribute('open')
  }

  clickOutside(e) {
    if (this.hasMenuTarget) {
      const isInExemptionContainer = this.hasExemptionContainersValue && this.exemptionContainerTargets.some((container) => container.contains(e.target))

      if (!isInExemptionContainer && this.isOpen) {
        this.menuTarget.close()
      }
    }
  }

  connect() {
    useClickOutside(this)
  }

  toggle() {
    if (this.isOpen) {
      this.menuTarget.close()
    } else {
      this.menuTarget.show()
    }
  }
}
