import { Controller } from '@hotwired/stimulus'
import camelCase from 'lodash/camelCase'

export default class extends Controller {
  static targets = []

  static values = {
    view: String,
  }

  toggle({ params }) {
    const { toggleField, toggleFields } = params

    if (toggleField) {
      this.toggleAvoField(toggleField)
    }

    if (toggleFields && toggleFields.length > 0) {
      toggleFields.forEach(this.toggleAvoField.bind(this))
    }
  }

  disable({ params }) {
    const { disableField, disableFields } = params

    if (disableField) {
      this.disableAvoField(disableField)
    }

    if (disableFields && disableFields.length > 0) {
      disableFields.forEach(this.disableAvoField.bind(this))
    }
  }

  // Private

  toggleAvoField(fieldName) {
    // compose the default wrapper data value
    const target = camelCase(`${fieldName}_wrapper`)
    const element = document.querySelector(`[data-resource-edit-target="${target}"]`)

    if (element) {
      element.classList.toggle('hidden')
    }
  }

  disableAvoField(fieldName) {
    // compose the default wrapper data value
    const target = camelCase(`${fieldName}_wrapper`)

    // find & disable inputs
    document.querySelectorAll(`[data-resource-edit-target="${target}"] input`).forEach(this.toggleItemDisabled)

    // find & disable select fields
    document.querySelectorAll(`[data-resource-edit-target="${target}"] select`).forEach(this.toggleItemDisabled)

    // find & disable buttons for belongs_to
    document.querySelectorAll(`[data-resource-edit-target="${target}"] [data-slot="value"] button`).forEach(this.toggleItemDisabled)
  }

  toggleItemDisabled(item) {
    item.disabled = !item.disabled
  }
}
