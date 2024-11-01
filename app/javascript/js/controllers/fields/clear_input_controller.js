import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'clearButton']

  showClearButton() {
    this.clearButtonTarget.classList.remove('hidden')
  }

  clearInput() {
    this.inputTarget.value = ''
    this.clearButtonTarget.classList.add('hidden')
  }
}
