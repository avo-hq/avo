import { AttributeObserver, Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'itemCheckbox',
    'checkbox',
    'selectAllOverlay',
    'unselectedMessage',
    'selectedMessage',
  ]

  static values = {
    pageCount: Number,
    selectedAll: Boolean,
    selectedAllQuery: String,
  }

  connect() {
    this.resourceName = this.element.dataset.resourceName
    this.selectedResourcesObserver = new AttributeObserver(this.element, 'data-selected-resources', this)
    this.selectedResourcesObserver.start()
  }

  elementAttributeValueChanged(element) {
    // Check if anything is selected.
    const selectedResources = JSON.parse(element.dataset.selectedResources)
    // If all are selected, mark the checkbox as checked.
    const rowCount = this.element.querySelectorAll('tbody tr').length
    // Reset the checkbox
    this.checkboxTarget.indeterminate = false
    this.checkboxTarget.checked = false

    if (selectedResources.length === rowCount) {
      this.checkboxTarget.checked = true
    } else if (selectedResources.length === 0) {
      // If nothing is selected, mark the checkbox as unchecked.
      this.checkboxTarget.checked = false
    } else if (selectedResources.length > 0 && selectedResources.length < rowCount) {
      // If some are selected, mark the checkbox as indeterminate.
      this.checkboxTarget.indeterminate = true
    }
  }

  disconnect() {
    this.selectedResourcesObserver.stop()
  }

  toggle(event) {
    const checked = !!event.target.checked
    this.itemCheckboxTargets.forEach((checkbox) => checkbox.checked !== checked && checkbox.click())

    if (this.selectAllEnabled()) {
      this.selectAllOverlay(checked)

      // When de-selecting everything, ensure the selectAll toggle is false and hide overlay.
      if (!checked) {
        this.resetUnselected()
      }
    }
  }

  selectRow() {
    let allSelected = true
    // eslint-disable-next-line no-return-assign
    this.itemCheckboxTargets.forEach((checkbox) => allSelected = allSelected && checkbox.checked)
    this.checkboxTarget.checked = allSelected

    if (this.selectAllEnabled()) {
      this.selectAllOverlay(allSelected)
      this.resetUnselected()
    }

    this.updateLinks('resourceIds')
  }

  selectAll(event) {
    event.preventDefault()

    this.selectedAllValue = !this.selectedAllValue
    this.unselectedMessageTarget.classList.toggle('hidden')
    this.selectedMessageTarget.classList.toggle('hidden')

    if (this.selectedAllValue) {
      this.updateLinks('selectedQuery')
    } else {
      this.updateLinks('resourceIds')
    }
  }

  updateLinks(param) {
    let resourceIds = ''
    let selectedQuery = ''

    if (param === 'resourceIds') {
      resourceIds = JSON.parse(this.element.dataset.selectedResources).join(',')
    } else if (param === 'selectedQuery') {
      selectedQuery = this.element.dataset.itemSelectAllSelectedAllQueryValue
    }

    document.querySelectorAll('[data-target="actions-list"] > a').forEach((link) => {
      try {
        const url = new URL(link.href)

        Array.from(url.searchParams.keys())
          .filter((key) => key.startsWith('fields['))
          .forEach((key) => url.searchParams.delete(key))

        if (param === 'resourceIds') {
          url.searchParams.set('fields[avo_resource_ids]', resourceIds)
          url.searchParams.set('fields[avo_selected_all]', 'false')
        } else if (param === 'selectedQuery') {
          url.searchParams.set('fields[avo_index_query]', selectedQuery)
          url.searchParams.set('fields[avo_selected_all]', 'true')
        }

        link.href = url.toString()
      } catch (error) {
        console.error('Error updating link:', link, error)
      }
    })
  }

  resetUnselected() {
    this.selectedAllValue = false
    this.unselectedMessageTarget.classList.remove('hidden')
    this.selectedMessageTarget.classList.add('hidden')
  }

  selectAllOverlay(show) {
    if (show) {
      this.selectAllOverlayTarget.classList.remove('hidden')
    } else {
      this.selectAllOverlayTarget.classList.add('hidden')
    }
  }

  // True if there are more pages available and if query encryption run successfully
  selectAllEnabled() {
    return this.pageCountValue > 1 && this.selectedAllQueryValue !== 'select_all_disabled'
  }
}
