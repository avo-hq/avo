import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['controllerDiv', 'resourceIds']

  connect() {
    this.resourceIdsTarget.value = this.resourceIds
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
