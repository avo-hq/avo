import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['controllerDiv', 'resourceIds', 'form', 'selectedQuery']

  connect() {
    this.resourceIdsTarget.value = this.resourceIds
    this.selectedQueryTarget.value = this.selectedQuery

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

  get selectedQuery() {
    try {
      return document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`).dataset.selectedQuery
    } catch (error) {
      return []
    }
  }
}
