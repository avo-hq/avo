import { Controller } from '@hotwired/stimulus'

// Used as a custom Stream Action <turbo-stream action="update-belongs-to" />
export default class extends Controller {
  static values = {
    polymorphic: Boolean,
    searchable: Boolean,
    targetName: String,
    relationName: String,
    // The frame this field's "Create new" dialog opens in. Stacked dialogs can hold fields with the
    // same name (a self-referencing belongs_to), so the frame tells the field that opened the dialog apart.
    frameId: String,
  }

  beforeStreamRender(event) {
    const { relationName, targetName, frameId } = event.target.dataset
    if (event.target.action !== 'update-belongs-to' || this.relationNameValue !== relationName) return
    // Streams built without them (an overridden `create_success_action`) update every field for the relation.
    if (targetName && this.targetNameValue !== targetName) return
    if (frameId && this.frameIdValue !== frameId) return

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
    this.element.querySelector(`input[name="${CSS.escape(this.targetNameValue)}"][type="hidden"]`).value = stream.dataset.targetRecordId
    // Update the label
    this.element.querySelector(`input[name="${CSS.escape(this.targetNameValue)}"][type="text"]`).value = stream.dataset.targetResourceLabel
  }

  updateNonSearchable(stream) {
    const select = this.element.querySelector(`select[name="${CSS.escape(this.targetNameValue)}"]`)
    const option = document.createElement('option')
    option.value = stream.dataset.targetRecordId
    option.text = stream.dataset.targetResourceLabel
    option.selected = 'selected'

    select.appendChild(option)
  }
}
