import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['controllerDiv', 'resourceIds', 'submit', 'selectedAllQuery']

  connect() {
    if (this.resourceIdsTarget.value === '') {
      this.resourceIdsTarget.value = this.resourceIds
    }

    // This value is picked up from the DOM so we check true/false as strings
    if (this.selectionOptions.itemSelectAllSelectedAllValue === 'true') {
      this.selectedAllQueryTarget.value = this.selectionOptions.itemSelectAllSelectedAllQueryValue
    }

    if (this.noConfirmation) {
      this.submitTarget.click()
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
      return JSON.parse(this.selectionOptions.selectedResources)
    } catch (error) {
      return []
    }
  }

  get selectionOptions() {
    try {
      return document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`).dataset
    } catch (error) {
      return []
    }
  }
}
