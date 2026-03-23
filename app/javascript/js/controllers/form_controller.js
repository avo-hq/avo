import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="form"
export default class extends Controller {
  static targets = ['submitButton']

  connect() {
    this.checkRequiredFields()
    this.boundCheck = this.checkRequiredFields.bind(this)
    this.element.addEventListener('input', this.boundCheck)
    this.element.addEventListener('change', this.boundCheck)
  }

  disconnect() {
    this.element.removeEventListener('input', this.boundCheck)
    this.element.removeEventListener('change', this.boundCheck)
  }

  submit() {
    if (!this.allRequiredFieldsFilled()) return

    this.element.requestSubmit()
  }

  checkRequiredFields() {
    if (!this.hasSubmitButtonTarget) return
    const requiredFieldsFilled = this.allRequiredFieldsFilled()
    this.submitButtonTarget.disabled = !requiredFieldsFilled
  }

  allRequiredFieldsFilled() {
    const requiredWrappers = Array.from(this.element.querySelectorAll('[data-required]'))
    return requiredWrappers.every(wrapper => this.isFieldFilled(wrapper))
  }

  isFieldFilled(wrapper) {
   const input = wrapper.querySelector(
      'select[name*="["], input[name*="["]:not([type="hidden"]), textarea[name*="["]'
    ) || wrapper.querySelector('input[type="hidden"][name*="["]')

    if (!input) return true // Not recognizable, assume filled

    const val = input.value.trim()
    return val !== '' && val !== 'null' && val !== '[]' && val !== '{}'
  }
}
