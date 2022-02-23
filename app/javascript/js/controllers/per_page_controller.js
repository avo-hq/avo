import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['selector']

  get turboFrame() {
    return this.selectorTarget.dataset.turboFrame
  }

  reload() {
    document.querySelector(`[data-per-page-option="${this.selectorTarget.value}"][data-turbo-frame="${this.turboFrame}"]`).click()
  }
}
