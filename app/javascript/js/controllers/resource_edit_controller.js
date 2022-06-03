import { Controller } from '@hotwired/stimulus'
import camelCase from 'lodash/camelCase'

export default class extends Controller {
  // static targets = ['parentController', 'skillsTagsWrapper']
  static targets = []

  static values = {
    view: String,
  }

  connect() {
    console.log('BASE resource_edit_controller', this.context.targets, this.constructor.targets, 1, this.viewValue)
    // this.application.getControllerForElementAndIdentifier(this.otherTarget, 'other')
    // console.log('this.firstNameTextWrapperTarget->', this.firstNameTextWrapperTarget)
  }

  // emailUpdate(e) {
  //   console.log('Updated field->', e, e.target.value)
  // }

  atInput(e) {
    console.log('BASE At Input ()->', e, e.target.value, this.viewValue)
    // for trix use the innerHTML property
    // console.log('BASE At Input ()->', e, e.target.innerHTML)
  }

  toggle({ params }) {
    const { field } = params
    if (field) {
      const target = camelCase(`${field}_wrapper`)
      const element = document.querySelector(`[data-resource-edit-target="${target}"]`)

      if (element) {
        element.classList.toggle('hidden')
      }
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
