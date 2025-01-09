import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['panel']

  checkbox = {}

  get actionLinks() {
    return document.querySelectorAll(
      'a[data-actions-picker-target="resourceAction"]',
    )
  }

  get currentIds() {
    try {
      return JSON.parse(this.stateHolderElement.dataset.selectedResources)
    } catch (error) {
      return []
    }
  }

  set currentIds(value) {
    this.stateHolderElement.dataset.selectedResources = JSON.stringify(value)

    if (this.actionLinks.length > 0) {
      if (value.length > 0) {
        this.enableResourceActions()
      } else {
        this.disableResourceActions()
      }
    }
  }

  connect() {
    this.resourceName = this.element.dataset.resourceName
    this.resourceId = this.element.dataset.resourceId
    this.stateHolderElement = document.querySelector(
      `[data-selected-resources-name="${this.resourceName}"]`,
    )
  }

  addToSelected() {
    const ids = this.currentIds

    ids.push(this.resourceId)

    // Mark the row as selected
    this.element.closest('tr').classList.add('selected-row')

    this.currentIds = ids
  }

  removeFromSelected() {
    // Un-mark the row as selected
    this.element.closest('tr').classList.remove('selected-row')

    this.currentIds = this.currentIds.filter(
      (item) => item.toString() !== this.resourceId,
    )
  }

  toggle(event) {
    this.checkbox = event.target

    if (this.checkbox.checked) {
      this.addToSelected()
    } else {
      this.removeFromSelected()
    }
  }

  enableResourceActions() {
    this.actionLinks.forEach((link) => {
      link.classList.add(link.dataset.enabledClasses)
      link.classList.remove(link.dataset.disabledClasses)
      link.setAttribute('data-href', link.getAttribute('href'))
      link.dataset.disabled = false
    })
  }

  disableResourceActions() {
    this.actionLinks.forEach((link) => {
      link.classList.remove(link.dataset.enabledClasses)
      link.classList.add(link.dataset.disabledClasses)
      link.setAttribute('href', link.getAttribute('data-href'))
      link.dataset.disabled = true
    })
  }
}
