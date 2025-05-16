import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['label', 'valueInput', 'visibleInput']

  update() {
    this.valueInputTarget.value = this.visibleInputTarget.value
    this.labelTarget.textContent = this.valueInputTarget.value
  }
}
