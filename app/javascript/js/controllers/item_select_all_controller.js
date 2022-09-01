import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['itemCheckbox', 'checkbox', 'selectAllOvelay', 'unselectedMessage', 'selectedMessage']

  static values = {
    selectedAll: Boolean,
    selectedAllQuery: String,
  }

  connect() {
    this.resourceName = this.element.dataset.resourceName
  }

  toggle(event) {
    const checked = !!event.target.checked
    document.querySelectorAll(`[data-controller="item-selector"][data-resource-name="${this.resourceName}"] input[type=checkbox]`)
      .forEach((checkbox) => checkbox.checked !== checked && checkbox.click())

    this.selectAllOverlay(checked)

    // When de-selecting everything, ensure the selectAll toggle is false and hide overlay.
    if (!checked) {
      this.resetUnselected()
    }
  }

  selectRow() {
    let allSelected = true
    // eslint-disable-next-line no-return-assign
    this.itemCheckboxTargets.forEach((checkbox) => allSelected = allSelected && checkbox.checked)
    this.checkboxTarget.checked = allSelected

    this.selectAllOverlay(allSelected)
    this.resetUnselected()
  }

  selectAll(event) {
    event.preventDefault()

    this.selectedAllValue = !this.selectedAllValue
    this.unselectedMessageTarget.classList.toggle('hidden')
    this.selectedMessageTarget.classList.toggle('hidden')
  }

  resetUnselected() {
    this.selectedAllValue = false
    this.unselectedMessageTarget.classList.remove('hidden')
    this.selectedMessageTarget.classList.add('hidden')
  }

  selectAllOverlay(show) {
    if (show) {
      this.selectAllOvelayTarget.classList.remove('hidden')
    } else {
      this.selectAllOvelayTarget.classList.add('hidden')
    }
  }
}
