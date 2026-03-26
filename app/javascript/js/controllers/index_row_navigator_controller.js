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
 * WHY ROW HOTKEYS ARE HANDLED SEPARATELY:
 * The @github/hotkey library scans for data-hotkey attributes on page load
 * and registers handlers for ALL matching elements. If we leave data-hotkey
 * on row controls, the library will register all of them, and pressing a key
 * will trigger the LAST-REGISTERED element (bug). If we later change which
 * elements have the attribute, the library doesn't re-scan, so our changes
 * have no effect.
 *
 * SOLUTION:
 * 1. Remove data-hotkey from all row controls early (before hotkey library scans)
 * 2. Store the original values in data-hotkey-original
 * 3. When a row is focused, add data-hotkey back to ONLY that row's controls
 * 4. When the user presses a hotkey, our controller handles it and prevents
 *    other listeners via stopImmediatePropagation
 *
 * KEY DESIGN DECISIONS:
 * - currentIndex = -1 when no row is focused (safe default)
 * - We remove/add data-hotkey dynamically so the library sees the current state
 * - stopImmediatePropagation prevents other keyboard handlers from firing
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

    // Remove data-hotkey from row controls before @github/hotkey library scans
    // Store the original values so we can restore them for the focused row only
    this.element.querySelectorAll('tr[data-visit-path] [data-hotkey]').forEach(control => {
      const hotkey = control.getAttribute('data-hotkey')
      control.setAttribute('data-hotkey-original', hotkey)
      control.removeAttribute('data-hotkey')
    })
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
    this.syncRowHotkeys(rows)
  }

  normalizeCurrentIndex(rowsLength) {
    if (this.currentIndex < -1) return -1
    if (this.currentIndex >= rowsLength) return rowsLength - 1

    return this.currentIndex
  }

  syncRowHotkeys(rows) {
    // Add data-hotkey back ONLY for the focused row so the library can handle it
    // (if it re-scans) or so it's available for our manual handling
    rows.forEach((row, index) => {
      const controls = row.querySelectorAll('[data-hotkey-original]')
      controls.forEach(control => {
        if (index === this.currentIndex) {
          // Restore hotkey on focused row
          const hotkeyValue = control.getAttribute('data-hotkey-original')
          control.setAttribute('data-hotkey', hotkeyValue)
        } else {
          // Remove hotkey from non-focused rows
          control.removeAttribute('data-hotkey')
        }
      })
    })
  }

  handleRowHotkey(event, rows) {
    const focusedRow = rows[this.currentIndex]
    if (!focusedRow) return false

    // The hotkey is now on the focused row (added by syncRowHotkeys)
    const control = focusedRow.querySelector(`[data-hotkey="${event.key}"]`)
    if (!control) return false

    event.preventDefault()
    event.stopImmediatePropagation() // Prevent @github/hotkey library from firing
    control.click()
    return true
  }

  clearFocus(rows) {
    rows.forEach((r) => r.classList.remove('is-keyboard-focused'))
    this.currentIndex = -1
    // Clear all hotkeys when focus is cleared
    rows.forEach((row) => {
      row.querySelectorAll('[data-hotkey-original]').forEach(control => {
        control.removeAttribute('data-hotkey')
      })
    })
  }
}
