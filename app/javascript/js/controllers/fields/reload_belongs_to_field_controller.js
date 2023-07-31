import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    polymorphic: Boolean,
    searchable: Boolean,
    targetName: String,
    relationName: String
  }

  beforeStreamRender(event) {
    const { relationName, targetResourceId, targetResourceLabel, targetResourceClass } = event.target.dataset

    if (event.target.action !== "update-belongs-to" || this.relationNameValue !== relationName) {
      return false;
    }

    event.detail.render = (stream) => {
      if (this.searchableValue) {
        // Update the id component
        document.querySelector(`input[name="${this.targetNameValue}"][type="hidden"]`).value = targetResourceId
        // Update the label
        document.querySelector(`input[name="${this.targetNameValue}"][type="text"]`).value = targetResourceLabel

      } else{

        let searchContext = document;
        // if polymorphic, search for the select in the correct sub-container
        if (this.polymorphicValue) {
          searchContext = document.querySelector(`[data-type="${targetResourceClass}"]`)
        }

        const select = searchContext.querySelector(`select[name="${this.targetNameValue}"]`)
        const option = document.createElement('option')
        option.value = targetResourceId
        option.text = targetResourceLabel
        option.selected = true
        select.appendChild(option)
      }
    };
  }
}
