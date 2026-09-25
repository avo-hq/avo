import { Controller } from '@hotwired/stimulus'

// Used as a custom Stream Action <turbo-stream action="update-belongs-to" />
export default class extends Controller {
  static values = {
    polymorphic: Boolean,
    searchable: Boolean,
    targetName: String,
    relationName: String,
  }

  beforeStreamRender(event) {
    const { relationName, targetName } = event.target.dataset
    if (
      event.target.action !== 'update-belongs-to' ||
      this.relationNameValue !== relationName ||
      this.targetNameValue !== targetName
    ) {
      return false
    }

    event.detail.render = (stream) => {
      if (this.searchableValue) {
        this.updateSearchable(stream)
      } else {
        this.updateNonSearchable(stream)
      }
    }
  }

  updateSearchable(stream) {
    // Update the id component
    this.element.querySelector(`input[name="${this.targetNameValue}"][type="hidden"]`).value = stream.dataset.targetRecordId
    // Update the label
    this.element.querySelector(`input[name="${this.targetNameValue}"][type="text"]`).value = stream.dataset.targetResourceLabel
  }

  updateNonSearchable(stream) {
    const select = this.element.querySelector(`select[name="${this.targetNameValue}"]`)
    const option = document.createElement('option')
    option.value = stream.dataset.targetRecordId
    option.text = stream.dataset.targetResourceLabel
    option.selected = 'selected'

    select.appendChild(option)
  }
}
