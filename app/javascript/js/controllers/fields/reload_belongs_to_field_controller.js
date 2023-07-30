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
          // Update the id component
          document.querySelector(`input[name="${this.targetNameValue}"][type="hidden"]`).value = targetResourceId
          if (this.searchableValue) {
            // Update the label
            document.querySelector(`input[name="${this.targetNameValue}"][type="text"]`).value = targetResourceLabel
          }
        }

      } else {
        fallbackRender(stream)
      }
    };
  }
}
