import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['resourceIds', 'form', 'selectedAllQuery']

  static values = {
    noConfirmation: Boolean,
    resourceName: Boolean,
  }

  connect() {
    if (this.resourceIdsTarget.value === '') {
      this.resourceIdsTarget.value = this.resourceIds
    }

    // This value is picked up from the DOM so we check true/false as strings
    if (this.selectionOptions.itemSelectAllSelectedAllValue === 'true') {
      this.selectedAllQueryTarget.value = this.selectionOptions.itemSelectAllSelectedAllQueryValue
    }

    if (this.noConfirmationValue) {
      this.formTarget.requestSubmit()
    } else {
      this.element.classList.remove('hidden')
    }
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
      return document.querySelector(`[data-selected-resources-name="${this.resourceNameValue}"]`).dataset
    } catch (error) {
      return []
    }
  }
}
