import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['label']

  update(e) {
    this.labelTarget.textContent = e.target.value
  }
}
