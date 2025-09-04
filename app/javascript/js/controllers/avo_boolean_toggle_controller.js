import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "track", "circle"]

  connect() {
    // Initialize classes based on initial state
    this.applyState(this.checkboxTarget.checked)

    this._boundToggle = this.toggle.bind(this)
    this.checkboxTarget.addEventListener('change', this._boundToggle)
  }

  disconnect() {
    if (this._boundToggle) this.checkboxTarget.removeEventListener('change', this._boundToggle)
  }

  toggle() {
    const isChecked = this.checkboxTarget.checked
    this.applyState(isChecked)
  }

  applyState(isChecked) {
    // Track background color via Tailwind classes
    this.trackTarget.classList.toggle('bg-blue-500', isChecked)
    this.trackTarget.classList.toggle('bg-gray-300', !isChecked)

    // Circle translation via Tailwind classes
    this.circleTarget.classList.toggle('translate-x-5', isChecked)
    this.circleTarget.classList.toggle('translate-x-0', !isChecked)
  }
}
