import { Controller } from '@hotwired/stimulus'
import camelCase from 'lodash/camelCase'

export default class extends Controller {
  static targets = []

  static values = {
    view: String,
  }

  debugOnInput(e) {
    // eslint-disable-next-line no-console
    console.log('onInput', e, e.target.value)
  }

  toggle({ params }) {
    const { toggleTarget, toggleTargets } = params

    if (toggleTarget) {
      this.toggleAvoTarget(toggleTarget)
    }

    if (toggleTargets && toggleTargets.length > 0) {
      toggleTargets.forEach(this.toggleAvoTarget.bind(this))
    }
  }

  disable({ params }) {
    const { disableTarget, disableTargets } = params

    if (disableTarget) {
      this.disableAvoTarget(disableTarget)
    }

    if (disableTargets && disableTargets.length > 0) {
      disableTargets.forEach(this.disableAvoTarget.bind(this))
    }
  }

  // Private

  toggleAvoTarget(targetName) {
    // compose the default wrapper data value
    const target = camelCase(targetName)
    const element = document.querySelector(`[data-resource-edit-target="${target}"]`)

    if (element) {
      element.classList.toggle('hidden')
    }
  }

  disableAvoTarget(targetName) {
    // compose the default wrapper data value
    const target = camelCase(targetName)

    // find & disable direct selector
    document.querySelectorAll(`[data-resource-edit-target="${target}"]`).forEach(this.toggleItemDisabled)

    // find & disable inputs
    document.querySelectorAll(`[data-resource-edit-target="${target}"] input`).forEach(this.toggleItemDisabled)

    // find & disable select fields
    document.querySelectorAll(`[data-resource-edit-target="${target}"] select`).forEach(this.toggleItemDisabled)

    // find & disable buttons for belongs_to
    document.querySelectorAll(`[data-resource-edit-target="${target}"] [data-slot="value"] button`).forEach(this.toggleItemDisabled)
  }

  toggleItemDisabled(item) {
    item.disabled = !item.disabled
  }
}
