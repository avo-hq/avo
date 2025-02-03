import { Controller } from '@hotwired/stimulus'
import { leave, toggle } from 'el-transition'
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
  }

  clickOutside(e) {
    if (this.hasPanelTarget) {
      const isInExemptionContainer = this.hasExemptionContainersValue && this.exemptionContainerTargets.some((container) => container.contains(e.target))

      if (!isInExemptionContainer && !this.panelTarget.classList.contains('hidden')) {
        leave(this.panelTarget)
      }
    }
  }

  togglePanel() {
    if (this.hasPanelTarget) {
      toggle(this.panelTarget)
    }
  }

  outlet({ params }) {
    const { outlet } = params

    if (outlet && document.querySelector(outlet)) {
      document.querySelector(outlet).classList.toggle('hidden')
    }
  }
}
