import { Controller } from '@hotwired/stimulus'

const TYPING_SELECTOR = 'input, textarea, select, [contenteditable]'

export default class extends Controller {
  connect() {
    this.currentIndex = -1
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleDropdownOpen = this.handleDropdownOpen.bind(this)
    document.addEventListener('keydown', this.handleKeydown)
    document.addEventListener('dropdown-menu:open', this.handleDropdownOpen)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
    document.removeEventListener('dropdown-menu:open', this.handleDropdownOpen)
  }

  handleDropdownOpen() {
    const rows = Array.from(this.element.querySelectorAll('tr[data-visit-path]'))
    if (rows.length) this.clearFocus(rows)
  }

  handleKeydown(event) {
    if (event.defaultPrevented) return
    if (document.body.classList.contains('modal-open')) return
    if (document.body.classList.contains('dropdown-open')) return
    if (event.target.closest(TYPING_SELECTOR)) return
    if (!['ArrowDown', 'ArrowUp', 'Enter', 'Escape', ' '].includes(event.key)) return
    if (event.repeat && (event.key === 'Enter' || event.key === 'Escape' || event.key === ' ')) return

    const rows = Array.from(this.element.querySelectorAll('tr[data-visit-path]'))
    if (!rows.length) return
    this.currentIndex = this.normalizeCurrentIndex(rows.length)

    if (event.key === 'Escape') {
      if (this.currentIndex !== -1) {
        event.preventDefault()
        this.clearFocus(rows)

        return
      }

      // No keyboard-focused row — clear checkbox selection if any
      const selectAllController = this.application.getControllerForElementAndIdentifier(
        this.element.querySelector('[data-controller~="item-select-all"]'),
        'item-select-all',
      )
      if (selectAllController) {
        const selected = JSON.parse(selectAllController.element.dataset.selectedResources || '[]')
        if (selected.length > 0) {
          event.preventDefault()
          selectAllController.deselectAll()
        }
      }

      return
    }

    if (event.key === 'Enter') {
      if (this.currentIndex === -1) return
      event.preventDefault()
      const row = rows[this.currentIndex]
      if (row?.dataset.visitPath) window.Turbo.visit(row.dataset.visitPath)

      return
    }

    if (event.key === ' ') {
      if (this.currentIndex === -1) return
      event.preventDefault()
      const checkbox = rows[this.currentIndex].querySelector('[data-item-select-all-target="itemCheckbox"]')
      if (checkbox) checkbox.click()

      return
    }

    // ArrowDown / ArrowUp
    event.preventDefault()
    if (event.key === 'ArrowDown') {
      this.currentIndex = this.currentIndex < rows.length - 1 ? this.currentIndex + 1 : 0
    } else {
      this.currentIndex = this.currentIndex > 0 ? this.currentIndex - 1 : rows.length - 1
    }

    rows.forEach((r, i) => r.classList.toggle('is-keyboard-focused', i === this.currentIndex))
    rows[this.currentIndex].scrollIntoView({ block: 'nearest' })
  }

  normalizeCurrentIndex(rowsLength) {
    if (this.currentIndex < -1) return -1
    if (this.currentIndex >= rowsLength) return rowsLength - 1

    return this.currentIndex
  }

  clearFocus(rows) {
    rows.forEach((r) => r.classList.remove('is-keyboard-focused'))
    this.currentIndex = -1
  }
}
