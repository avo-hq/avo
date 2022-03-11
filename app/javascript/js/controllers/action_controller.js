import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['controllerDiv', 'resourceIds', 'form']

  connect() {
    this.resourceIdsTarget.value = this.resourceIds

    if (this.noConfirmation) {
      this.formTarget.submit()
    } else {
      this.controllerDivTarget.classList.remove('hidden')
    }
  }

  get noConfirmation() {
    return castBoolean(this.controllerDivTarget.dataset.noConfirmation)
  }

  get resourceName() {
    return this.controllerDivTarget.dataset.resourceName
  }

  get resourceIds() {
    try {
      return JSON.parse(document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`).dataset.selectedResources)
    } catch (error) {
      return []
    }
  }
}
