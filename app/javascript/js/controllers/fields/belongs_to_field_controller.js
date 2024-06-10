import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select', 'type', 'container']

  connect() {
    this.changeType() // Do the initial type change
  }

  changeType() {
    this.#hideAllTypes()
    this.#showType(this.selectTarget.value)
  }

  #hideAllTypes() {
    this.containerTarget.innerHTML = ''
  }

  #showType(type) {
    const target = this.typeTargets.find((typeTarget) => typeTarget.dataset.type === type)
    if (target) {
      this.containerTarget.appendChild(target.content.cloneNode(true))
    }
  }
}
