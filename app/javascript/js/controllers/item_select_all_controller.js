import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['itemCheckbox', 'checkbox']

  connect() {
    this.resourceName = this.element.dataset.resourceName
  }

  toggle(event) {
    const value = !!event.target.checked
    document.querySelectorAll(`[data-controller="item-selector"][data-resource-name="${this.resourceName}"] input[type=checkbox]`)
      .forEach((checkbox) => checkbox.checked != value && checkbox.click())
  }

  update() {
    let allSelected = true
    this.itemCheckboxTargets.forEach((checkbox) => allSelected = allSelected && checkbox.checked)
    this.checkboxTarget.checked = allSelected
  }
}
