import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['panel']

  checkbox = {}

  get actionLinks() {
    return document.querySelectorAll(
      'a[data-actions-picker-target="resourceAction"]',
    )
  }

  // The bulk-update toolbar button uses a DISTINCT target attribute so the
  // Actions picker controller's click handler doesn't grab it (the Actions
  // path is hardcoded to MODAL_FRAME_ID; bulk update routes to SLIDE_OVER_FRAME_ID).
  get bulkUpdateLinks() {
    return document.querySelectorAll(
      'a[data-bulk-update-target="resourceAction"]',
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

    // Bulk update enables at N >= 2 (the N=1 case is better served by the
    // standard :edit form). Existing Actions threshold (N >= 1) is unchanged.
    if (this.bulkUpdateLinks.length > 0) {
      if (value.length >= 2) {
        this.enableBulkUpdateAction()
      } else {
        this.disableBulkUpdateAction()
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

    // Mark the row as selected if on table view
    if (this.element.closest('tr')) {
      this.element.closest('tr').classList.add('selected-row')
    }

    this.currentIds = ids
  }

  removeFromSelected() {
    // Un-mark the row as selected if on table view
    if (this.element.closest('tr')) {
      this.element.closest('tr').classList.remove('selected-row')
    }

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
      // Enable only if is on the same resource context
      // Avoiding to enable unrelated actions when selecting items on a has many table
      if (link.dataset.resourceName === this.resourceName) {
        link.classList.remove(link.dataset.disabledClasses)
        link.setAttribute('data-href', link.getAttribute('href'))
        link.dataset.disabled = false
      }
    })
  }

  disableResourceActions() {
    this.actionLinks.forEach((link) => {
      // Disable only if is on the same resource context
      // Avoiding to disable unrelated actions when selecting items on a has many table
      if (link.dataset.resourceName === this.resourceName) {
        link.classList.add(link.dataset.disabledClasses)
        link.setAttribute('href', link.getAttribute('data-href'))
        link.dataset.disabled = true
      }
    })
  }

  // Bulk update parallels resource actions but enables only at N >= 2 (the
  // N=1 case is better served by the standard :edit form; per-field
  // "all share X" / "K different values" semantics are meaningless for one
  // record). The toggle target is `a[data-bulk-update-target="resourceAction"]`,
  // distinct from the Actions picker's `data-actions-picker-target` selector so
  // the same link cannot be hijacked by `actions_picker_controller#visitAction`
  // (which would route the click into the modal frame, wrong for bulk update).
  enableBulkUpdateAction() {
    this.bulkUpdateLinks.forEach((link) => {
      if (link.dataset.resourceName === this.resourceName) {
        link.classList.remove(link.dataset.disabledClasses)
        link.setAttribute('data-href', link.getAttribute('href'))
        link.dataset.disabled = false
      }
    })
  }

  disableBulkUpdateAction() {
    this.bulkUpdateLinks.forEach((link) => {
      if (link.dataset.resourceName === this.resourceName) {
        link.classList.add(link.dataset.disabledClasses)
        link.setAttribute('href', link.getAttribute('data-href'))
        link.dataset.disabled = true
      }
    })
  }
}
