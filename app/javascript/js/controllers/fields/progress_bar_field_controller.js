import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['label', 'fakeInput', 'realInput']

  update() {
    this.realInputTarget.value = this.fakeInputTarget.value
    this.labelTarget.textContent = this.realInputTarget.value
  }
}
