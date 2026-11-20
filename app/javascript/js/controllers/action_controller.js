import { Controller } from '@hotwired/stimulus'
import { clearSelections } from '../index_state'
import { toggleHidden } from '../helpers/toggle_hidden'

// What a user types into or picks from. Trix, Tiptap and the tags field edit a contenteditable element.
const INTERACTIVE_CONTROLS = 'input:not([type="hidden"]), select, textarea, [contenteditable]:not([contenteditable="false"])'

export default class extends Controller {
  static targets = ['resourceIds', 'form', 'selectedAll', 'indexQuery', 'requiredField']

  static values = {
    confirmation: Boolean,
    resourceName: String,
  }

  connect() {
    this.formTarget.addEventListener('submit', this.submit)
    // A required field drops its error as soon as the user fills it in.
    this.formTarget.addEventListener('input', this.clearFilledRequiredFields)
    this.formTarget.addEventListener('change', this.clearFilledRequiredFields)

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

  disconnect() {
    this.formTarget.removeEventListener('submit', this.submit)
    this.formTarget.removeEventListener('input', this.clearFilledRequiredFields)
    this.formTarget.removeEventListener('change', this.clearFilledRequiredFields)
  }

  submit = (event) => {
    // Without the confirmation modal the user never sees the fields, so there's nothing for them to fill in.
    if (this.confirmationValue && !this.validateRequiredFields()) {
      event.preventDefault()

      return
    }

    // Once an action runs on the selection, coming back to the index shouldn't select those rows again.
    clearSelections(this.resourceNameValue)
  }

  // Marks every required field the user left empty and focuses the first one.
  // Returns true when there's nothing left to fill in.
  validateRequiredFields() {
    const emptyFields = this.requiredFieldTargets.filter((field) => this.requiredFieldApplies(field) && !this.requiredFieldFilled(field))

    this.requiredFieldTargets.forEach((field) => this.toggleRequiredFieldError(field, emptyFields.includes(field)))

    if (emptyFields.length === 0) {
      return true
    }

    this.interactiveControls(emptyFields[0])[0]?.focus()

    return false
  }

  clearFilledRequiredFields = () => {
    this.requiredFieldTargets.forEach((field) => {
      if (this.requiredFieldFilled(field)) {
        this.toggleRequiredFieldError(field, false)
      }
    })
  }

  // A field the user can't see or change can't hold back the submit.
  requiredFieldApplies(field) {
    return field.getClientRects().length > 0 && this.interactiveControls(field).length > 0
  }

  // A field counts as filled when one of the inputs it submits has a value.
  requiredFieldFilled(field) {
    const controls = [...field.querySelectorAll('input[name], select[name], textarea[name]')].filter((control) => !control.disabled)
    // Rails pairs every checkbox with a hidden input of the same name that always sends a value.
    const checkboxNames = controls.filter((control) => control.type === 'checkbox').map((control) => control.name)

    return controls.some((control) => {
      if (control.type === 'checkbox' || control.type === 'radio') {
        return control.checked
      }

      if (control.type === 'hidden' && checkboxNames.includes(control.name)) {
        return false
      }

      if (control.type === 'file') {
        return control.files.length > 0
      }

      if (control.tagName === 'SELECT') {
        return [...control.selectedOptions].some((option) => option.value !== '')
      }

      return control.value.trim() !== ''
    })
  }

  toggleRequiredFieldError(field, invalid) {
    const error = field.querySelector('[data-action-target~="requiredFieldError"]')

    // The error shows exactly when the field is invalid.
    if (error && error.hidden === invalid) {
      toggleHidden(error)
    }

    this.interactiveControls(field).forEach((control) => {
      control.classList.toggle('input-field--error', invalid)

      if (invalid) {
        control.setAttribute('aria-invalid', 'true')
      } else {
        control.removeAttribute('aria-invalid')
      }
    })
  }

  interactiveControls(field) {
    return [...field.querySelectorAll(INTERACTIVE_CONTROLS)].filter((control) => !control.disabled)
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
