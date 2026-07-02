import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['resourceIds', 'form', 'selectedAll', 'indexQuery']

  static values = {
    confirmation: Boolean,
    resourceName: String,
  }

  connect() {
    if (this.resourceIdsTarget.value === '') {
      this.resourceIdsTarget.value = this.resourceIds
    }

    // Select all checkbox
    this.selectedAllTarget.value = this.selectionOptions.itemSelectAllSelectedAllValue

    // Encrypted and encoded index query when it is present (index view)
    if (this.selectionOptions.itemSelectAllSelectedAllQueryValue) {
      this.indexQueryTarget.value = this.selectionOptions.itemSelectAllSelectedAllQueryValue
    }

    if (this.confirmationValue) {
      this.element.classList.remove('hidden')
    } else {
      this.formTarget.requestSubmit()
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
