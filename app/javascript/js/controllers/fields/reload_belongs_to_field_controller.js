import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    polymorphic: Boolean,
    searchable: Boolean,
    targetName: String
  }

  beforeStreamRender(event) {
    const fallbackRender = event.detail.render;

    event.detail.render = (stream) => {
      if (stream.action === "update-belongs-to") {
        const { relationName, targetResourceId, targetResourceLabel, targetResourceClass } = stream.dataset

        if (this.polymorphicValue) {
        } else {
          if (this.searchableValue) {
            // Update the id component
            document.querySelector(`input[name="${this.targetNameValue}"][type="hidden"]`).value = targetResourceId
            // Update the label
            document.querySelector(`input[name="${this.targetNameValue}"][type="text"]`).value = targetResourceLabel
          } else{
            const select = document.querySelector(`select[name="${this.targetNameValue}"]`)
            const option = document.createElement('option')
            option.value = targetResourceId
            option.text = targetResourceLabel
            option.selected = true
            select.appendChild(option)
          }
        }

      } else {
        fallbackRender(stream)
      }
    };
  }
}
