import { Controller } from '@hotwired/stimulus'
import { leave, toggle } from 'el-transition'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['panel']

  static values = {
    // One may want to have an element that is exempt from triggerring the click outside event
    exemptionContainer: String,
  }

  get exemptionContainerTarget() {
    return document.querySelector(this.exemptionContainerValue)
  }

  connect() {
    useClickOutside(this)
  }

  clickOutside(e) {
    if (this.hasPanelTarget) {
      if (this.hasExemptionContainerValue) {
        const inExemptionContainer = this.exemptionContainerTarget.contains(e.target)

        if (!inExemptionContainer) {
          leave(this.panelTarget)
        }
      } else {
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
