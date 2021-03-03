import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['panel']

  checkbox = {}

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

  set currentIds(value) {
    this.stateHolderElement.dataset.selectedResources = JSON.stringify(value)

    if (this.actionsPanelPresent) {
      if (value.length > 0) {
        this.enableActionsPanel()
      } else {
        this.disableActionsPanel()
      }
    }
  }

  connect() {
    this.resourceName = this.element.dataset.resourceName
    this.resourceId = this.element.dataset.resourceId
    this.actionsButtonElement = document.querySelector(`[data-actions-dropdown-button="${this.resourceName}"]`)
    this.stateHolderElement = document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`)
  }

  addToSelected() {
    const ids = this.currentIds

    ids.push(this.resourceId)

    this.currentIds = ids
  }

  removeFromSelected() {
    this.currentIds = this.currentIds.filter((item) => item.toString() !== this.resourceId)
  }

  toggle(event) {
    this.checkbox = event.target

    if (this.checkbox.checked) {
      this.addToSelected()
    } else {
      this.removeFromSelected()
    }
  }

  enableActionsPanel() {
    this.actionsButtonElement.disabled = false
  }

  disableActionsPanel() {
    this.actionsButtonElement.disabled = true
  }
}
