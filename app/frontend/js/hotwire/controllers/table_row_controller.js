import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['panel']

  target = {}

  get resourceName() {
    return this.target.dataset.resourceName
  }

  get resourceId() {
    return this.target.dataset.resourceId
  }

  get currentIds() {
    try {
      return JSON.parse(document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`).dataset.selectedResources)
    } catch (error) {
      return []
    }
  }

  set currentIds(value) {
    document.querySelector(`[data-selected-resources-name="${this.resourceName}"]`).dataset.selectedResources = JSON.stringify(value)

    if (value.length > 0) {
      this.enableActionsPanel()
    } else {
      this.disableActionsPanel()
    }
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
    this.target = event.target

    if (this.target.checked) {
      this.addToSelected()
    } else {
      this.removeFromSelected()
    }
  }

  enableActionsPanel() {
    document.querySelector('.js-actions-dropdown-button').disabled = false
  }

  disableActionsPanel() {
    document.querySelector('.js-actions-dropdown-button').disabled = true
  }
}
