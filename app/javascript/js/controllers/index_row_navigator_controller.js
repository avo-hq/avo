/**
 * Index Row Navigator Controller
 *
 * Enables keyboard-driven navigation and hotkeys on table rows.
 *
 * FEATURES:
 * - Tab into the table (or press Shift+T) to focus it; then ↑/↓ navigate rows
 * - j / k focus the table AND advance one row (Gmail/GitHub-style power shortcut)
 * - Enter key to navigate to the focused row's detail page
 * - Space bar to toggle row selection checkbox
 * - Escape clears row focus, then blurs the table on a second press
 * - Row hotkeys: when a row is focused, hotkeys work for that row's controls
 *
 * FOCUS MODEL:
 * The <table> is focusable (tabindex=0, role=grid). Arrow keys / Enter / Space
 * are only handled when document.activeElement is inside the table — this lets
 * keyboard users scroll the page freely when the table isn't focused.
 * `aria-activedescendant` on the table points to the currently focused row.
 *
 * ROW HOTKEY HANDLING:
 * The @github/hotkey library scans data-hotkey attributes on page load.
 * To avoid the "last-registered wins" problem with multiple row controls
 * sharing the same hotkey, we:
 * 1. Remove data-hotkey from all row controls before the library scans
 * 2. Store original values in data-hotkey-original
 * 3. When a row is focused, add data-hotkey back ONLY to that row
 * 4. When a hotkey fires, prevent other handlers via stopImmediatePropagation
 *
 * KEY DESIGN DECISIONS:
 * - currentIndex = -1 when no row is focused (safe default)
 * - Guards prevent keyboard handling in modals, dropdowns, and input fields
 */

import { Controller } from '@hotwired/stimulus'

const TYPING_SELECTOR = 'input, textarea, select, [contenteditable]'

export default class extends Controller {
  static targets = ['table']

  initialize() {
    // Bind here, not in connect(). Stimulus fires tableTargetConnected() BEFORE
    // connect(), so binding in connect() would register the unbound prototype
    // method as the blur listener.
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleDropdownOpen = this.handleDropdownOpen.bind(this)
    this.handleAdvanceRequest = this.handleAdvanceRequest.bind(this)
    this.handleTableBlur = this.handleTableBlur.bind(this)
  }

  connect() {
    this.currentIndex = -1
    this.hotkeysEnabled = window.Avo?.configuration?.hotkeys?.enabled !== false

    document.addEventListener('keydown', this.handleKeydown)
    document.addEventListener('dropdown-menu:open', this.handleDropdownOpen)
    document.addEventListener('avo:advance-resource-table', this.handleAdvanceRequest)

    // Remove data-hotkey from row controls before @github/hotkey library scans
    // Store the original values so we can restore them for the focused row only
    if (this.hotkeysEnabled) {
      const controls = this.element.querySelectorAll('tr.has-row-link [data-hotkey]')
      controls.forEach((control) => {
        const hotkey = control.getAttribute('data-hotkey')
        control.setAttribute('data-hotkey-original', hotkey)
        control.removeAttribute('data-hotkey')
      })
    }
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
    document.removeEventListener('dropdown-menu:open', this.handleDropdownOpen)
    document.removeEventListener('avo:advance-resource-table', this.handleAdvanceRequest)
  }

  tableTargetConnected(table) {
    table.addEventListener('blur', this.handleTableBlur)
    // Turbo frame refreshes swap the <table>; reset stale row index from the old DOM.
    this.currentIndex = -1
  }

  tableTargetDisconnected(table) {
    table.removeEventListener('blur', this.handleTableBlur)
  }

  handleDropdownOpen() {
    const rows = this.rows()
    if (rows.length) this.clearFocus(rows)
  }

  // Fired by global hotkeys (j / k): focus the table AND advance one row.
  handleAdvanceRequest(event) {
    if (!this.hasTableTarget) return
    const direction = event.detail?.direction === 'previous' ? 'previous' : 'next'
    const rows = this.rows()
    if (!rows.length) return

    this.tableTarget.focus({ preventScroll: true })
    this.moveFocus(rows, direction)
  }

  handleTableBlur() {
    const rows = this.rows()
    if (rows.length) this.clearFocus(rows)
  }

  handleKeydown(event) {
    if (event.defaultPrevented) return
    if (document.body.classList.contains('modal-open')) return
    if (document.body.classList.contains('dropdown-open')) return
    if (event.target.closest(TYPING_SELECTOR)) return
    if (event.repeat && (event.key === 'Enter' || event.key === 'Escape' || event.key === ' ')) return

    const rows = this.rows()
    if (!rows.length) return

    // All navigation keys require the table to have focus. This frees ↑/↓ for
    // browser scrolling when the user hasn't engaged the table.
    if (!this.tableHasFocus()) return

    // Check for row hotkeys when a row is focused (only when hotkeys are enabled)
    if (this.hotkeysEnabled && this.currentIndex !== -1) {
      if (this.handleRowHotkey(event, rows)) {
        return
      }
    }

    // Only handle navigation keys below
    if (!['ArrowDown', 'ArrowUp', 'Enter', 'Escape', ' '].includes(event.key)) return

    this.currentIndex = this.normalizeCurrentIndex(rows.length)

    if (event.key === 'Escape') {
      if (this.currentIndex !== -1) {
        event.preventDefault()
        this.clearFocus(rows)

        return
      }

      // No keyboard-focused row: try clearing checkbox selection first; otherwise
      // blur the table so the user lands back on the body.
      const selectAllController = this.application.getControllerForElementAndIdentifier(
        this.element.querySelector('[data-controller~="item-select-all"]'),
        'item-select-all',
      )
      if (selectAllController) {
        const selected = JSON.parse(selectAllController.element.dataset.selectedResources || '[]')
        if (selected.length > 0) {
          event.preventDefault()
          selectAllController.deselectAll()

          return
        }
      }

      event.preventDefault()
      this.tableTarget.blur()

      return
    }

    if (event.key === 'Enter') {
      if (this.currentIndex === -1) return
      event.preventDefault()
      const row = rows[this.currentIndex]
      const href = row?.querySelector('a.row-link')?.href
      if (href) window.Turbo.visit(href)

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
    this.moveFocus(rows, event.key === 'ArrowDown' ? 'next' : 'previous')
  }

  moveFocus(rows, direction) {
    if (direction === 'next') {
      this.currentIndex = this.currentIndex < rows.length - 1 ? this.currentIndex + 1 : 0
    } else {
      this.currentIndex = this.currentIndex > 0 ? this.currentIndex - 1 : rows.length - 1
    }

    rows.forEach((r, i) => r.classList.toggle('is-keyboard-focused', i === this.currentIndex))
    rows[this.currentIndex].scrollIntoView({ block: 'nearest' })
    this.syncActiveDescendant(rows[this.currentIndex])
    if (this.hotkeysEnabled) this.syncRowHotkeys(rows)
  }

  rows() {
    return Array.from(this.element.querySelectorAll('tr.has-row-link'))
  }

  tableHasFocus() {
    if (!this.hasTableTarget) return false
    return this.tableTarget === document.activeElement || this.tableTarget.contains(document.activeElement)
  }

  syncActiveDescendant(row) {
    if (!this.hasTableTarget) return
    if (row?.id) {
      this.tableTarget.setAttribute('aria-activedescendant', row.id)
    } else {
      this.tableTarget.removeAttribute('aria-activedescendant')
    }
  }

  normalizeCurrentIndex(rowsLength) {
    if (this.currentIndex < -1) return -1
    if (this.currentIndex >= rowsLength) return rowsLength - 1

    return this.currentIndex
  }

  syncRowHotkeys(rows) {
    // Add data-hotkey back ONLY for the focused row
    rows.forEach((row, index) => {
      const controls = row.querySelectorAll('[data-hotkey-original]')
      controls.forEach((control) => {
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
    if (this.hasTableTarget) this.tableTarget.removeAttribute('aria-activedescendant')
    // Clear all hotkeys when focus is cleared
    rows.forEach((row) => {
      row.querySelectorAll('[data-hotkey-original]').forEach((control) => {
        control.removeAttribute('data-hotkey')
      })
    })
  }
}
