/**
 * Index Row Navigator Controller
 *
 * Enables keyboard-driven navigation and actions on table rows.
 *
 * FEATURES:
 * - Arrow keys (↑↓) to cycle through rows with visual focus indicator
 * - Enter key to navigate to the focused row's detail page
 * - Space bar to toggle row selection checkbox
 * - Escape to clear focus (or deselect all if no row is focused)
 * - Row-level hotkeys: when a row is focused, any hotkey defined on that
 *   row's controls (e.g., data-hotkey="i") will trigger that action
 *
 * WHY ROW HOTKEYS ARE HANDLED MANUALLY:
 * We don't rely on @github/hotkey library for row hotkeys because:
 * 1. The library only scans data-hotkey attributes on page load
 * 2. Dynamically adding/removing attributes doesn't trigger re-registration
 * 3. Managing multiple elements with the same hotkey is error-prone
 *
 * SOLUTION: The controller intercepts ALL keydown events and, when a row
 * is focused, looks for a matching [data-hotkey] element in that row and
 * clicks it directly. This ensures only the focused row's hotkeys work,
 * preventing the "last-registered hotkey wins" problem.
 *
 * KEY DESIGN DECISIONS:
 * - currentIndex = -1 when no row is focused (safe default)
 * - Row hotkeys only work when currentIndex !== -1
 * - We query [data-hotkey] directly instead of storing state to stay
 *   in sync with the HTML (simpler, no sync bugs)
 * - Guards prevent keyboard handling in modals, dropdowns, and input fields
 */

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
    if (event.repeat && (event.key === 'Enter' || event.key === 'Escape' || event.key === ' ')) return

    const rows = Array.from(this.element.querySelectorAll('tr[data-visit-path]'))
    if (!rows.length) return

    // Check for row hotkeys when a row is focused
    if (this.currentIndex !== -1 && this.handleRowHotkey(event, rows)) return

    // Only handle navigation keys below
    if (!['ArrowDown', 'ArrowUp', 'Enter', 'Escape', ' '].includes(event.key)) return

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

  handleRowHotkey(event, rows) {
    const focusedRow = rows[this.currentIndex]
    if (!focusedRow) return false

    // Find the first control in the focused row with a matching hotkey
    const control = focusedRow.querySelector(`[data-hotkey="${event.key}"]`)
    if (!control) return false

    event.preventDefault()
    control.click()
    return true
  }

  clearFocus(rows) {
    rows.forEach((r) => r.classList.remove('is-keyboard-focused'))
    this.currentIndex = -1
  }
}
