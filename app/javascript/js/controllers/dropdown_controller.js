import { Controller } from '@hotwired/stimulus'
import { leave, toggle } from 'el-transition'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['dropdownMenuComponent']

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
    if (this.hasDropdownMenuComponentTarget) {
      const isInExemptionContainer = this.hasExemptionContainersValue && this.exemptionContainerTargets.some((container) => container.contains(e.target))

      if (!isInExemptionContainer && !this.dropdownMenuComponentTarget.classList.contains('hidden')) {
        leave(this.dropdownMenuComponentTarget)
      }
    }
  }

  togglePanel() {
    if (this.hasDropdownMenuComponentTarget) {
      toggle(this.dropdownMenuComponentTarget)
    }
  }

  dropdownItemActions(event) {
    if (this.hasDropdownMenuComponentTarget) {
      const menuTarget = this.dropdownMenuComponentTarget
      const clickedInsideMenu = event?.target && menuTarget.contains(event.target)

      if (clickedInsideMenu) {
        leave(menuTarget)
      } else {
        toggle(menuTarget)
      }
    }
  }
}
