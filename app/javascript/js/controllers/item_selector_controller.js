import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['panel'];

  checkbox = {};

  enabledClasses = ['text-black', 'hover:bg-blue-500', 'hover:text-white']

  disabledClasses = ['text-gray-500']

  get actionsPanelPresent() {
    return this.actionsButtonElement !== null
  }

  get currentIds() {
    try {
      return JSON.parse(this.stateHolderElement.dataset.selectedResources)
    } catch (error) {
      return []
    }
  }

  get actionLinks() {
    return document.querySelectorAll(
      '.js-actions-dropdown a[data-actions-picker-target="resourceAction"]',
    )
  }

  set currentIds(value) {
    this.stateHolderElement.dataset.selectedResources = JSON.stringify(value)

    if (this.actionsPanelPresent) {
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
    this.actionsButtonElement = document.querySelector(
      `[data-actions-dropdown-button="${this.resourceName}"]`,
    )
    this.stateHolderElement = document.querySelector(
      `[data-selected-resources-name="${this.resourceName}"]`,
    )
  }

  addToSelected() {
    const ids = this.currentIds

    ids.push(this.resourceId)

    this.currentIds = ids
  }

  removeFromSelected() {
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
      link.classList.add(...this.enabledClasses)
      link.classList.remove(...this.disabledClasses)
      link.setAttribute('data-href', link.getAttribute('href'))
      link.dataset.disabled = false
    })
  }

  disableResourceActions() {
    this.actionLinks.forEach((link) => {
      link.classList.remove(...this.enabledClasses)
      link.classList.add(...this.disabledClasses)
      link.setAttribute('href', link.getAttribute('data-href'))
      link.dataset.disabled = true
    })
  }
}
