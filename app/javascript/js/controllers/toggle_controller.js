import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['panel']

  static values = {
    // One may want to have elements that are exempt from triggering the click outside event
    exemptionContainers: Array,
  }

  get exemptionContainerTargets() {
    return this.exemptionContainersValue.map((selector) => document.querySelector(selector)).filter(Boolean)
  }

  connect() {
    useClickOutside(this)
    this.hideTimeout = null
  }

  clickOutside(e) {
    if (this.hasPanelTarget) {
      const isInExemptionContainer = this.hasExemptionContainersValue && this.exemptionContainerTargets.some((container) => container.contains(e.target))

      if (!isInExemptionContainer && !this.panelTarget.hasAttribute('hidden')) {
        this.leave(this.panelTarget)
      }
    }
  }

  togglePanel() {
    if (this.hasPanelTarget) {
      this.toggle(this.panelTarget)
    }
  }

  showPanel() {
    // Clear any pending hide timeout
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }

    if (this.hasPanelTarget) {
      this.panelTarget.removeAttribute('hidden')
    }
  }

  hidePanel() {
    // Clear any existing timeout
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
    }

    // Add a small delay before hiding to allow smooth transition from button to panel
    this.hideTimeout = setTimeout(() => {
      if (this.hasPanelTarget) {
        this.panelTarget.setAttribute('hidden', true)
      }
      this.hideTimeout = null
    }, 100)
  }

  toggle(element) {
    element.toggleAttribute('hidden')
  }

  leave(element) {
    element.setAttribute('hidden', true)
  }

  outlet({ params }) {
    const { outlet } = params

    if (outlet && document.querySelector(outlet)) {
      this.toggle(document.querySelector(outlet))
    }
  }
}
