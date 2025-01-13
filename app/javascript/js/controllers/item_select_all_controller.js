import { Controller } from '@hotwired/stimulus'

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

    const resourceIds = JSON.parse(this.element.dataset.selectedResources).join(',')
    const allSelectedValue = ''
    this.updateLinks(resourceIds, allSelectedValue)
  }

  selectAll(event) {
    event.preventDefault()

    this.selectedAllValue = !this.selectedAllValue
    this.unselectedMessageTarget.classList.toggle('hidden')
    this.selectedMessageTarget.classList.toggle('hidden')

    const resourceIds = JSON.parse(this.element.dataset.selectedResources).join(',')
    const allSelectedValue = this.element.dataset.itemSelectAllSelectedAllQueryValue
    this.updateLinks(resourceIds, allSelectedValue)
  }

  updateLinks(resourceIds, allSelected) {
    document.querySelectorAll('[data-target="actions-list"] > a').forEach((link) => {
      try {
        const url = new URL(link.href)

        const fieldsParams = new URLSearchParams()
        fieldsParams.set('fields[avo_resource_ids]', resourceIds)
        fieldsParams.set('fields[avo_selected_query]', allSelected)

        url.searchParams.forEach((value, key) => {
          if (key.startsWith('fields[')) {
            url.searchParams.delete(key)
          }
        })

        fieldsParams.forEach((value, key) => {
          url.searchParams.set(key, value)
        })

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
