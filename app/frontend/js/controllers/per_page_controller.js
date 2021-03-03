import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['selector']

  reload() {
    document.querySelector(`[data-per-page-option="${this.selectorTarget.value}"]`).click()
  }
}
