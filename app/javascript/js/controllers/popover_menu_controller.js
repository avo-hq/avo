import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['searchInput', 'empty']

  // Used by both onToggle (auto-focus) and handleKeydown (arrow navigation).
  get focusableItems() {
    return [...this.element.querySelectorAll('a, button')].filter(
      (el) => !el.closest('[hidden]') && el.dataset.disabled !== 'true',
    )
  }

  connect() {
    // Store bound references so the exact same function can be removed in disconnect.
    // Without this, removeEventListener would silently fail and leak listeners.
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.boundOnToggle = this.onToggle.bind(this)
    this.element.addEventListener('toggle', this.boundOnToggle)
    this.element.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    this.element.removeEventListener('toggle', this.boundOnToggle)
    this.element.removeEventListener('keydown', this.boundHandleKeydown)
  }

  onToggle(event) {
    if (event.newState !== 'open') return

    // Each open starts unfiltered — a leftover query from the last visit would
    // silently hide items.
    if (this.hasSearchInputTarget) this.resetFilter()

    // requestAnimationFrame ensures the popover is fully rendered before we focus.
    // Focusing before the browser paints causes the scroll to jump in some cases.
    requestAnimationFrame(() => {
      // A searchable menu hands focus to its filter input so the user can just type.
      if (this.hasSearchInputTarget) {
        this.searchInputTarget.focus()
        return
      }

      const items = this.focusableItems
      if (items.length === 0) return

      // Focus the active item if present (e.g. current per-page selection),
      // otherwise fall back to the first item.
      const active = items.find((el) => el.classList.contains('dropdown-menu__item--active'))
      ;(active || items[0]).focus()
    })
  }

  // Narrows the rendered items to those whose text matches the query. Items are
  // queried at call time (not cached) so lazily loaded content — e.g. a
  // turbo-frame inside the list — is filterable as soon as it arrives. An item
  // carrying data-filter-text matches on that instead of its full text, so
  // decorations (timestamps, tags) don't count as matches.
  filter() {
    const query = this.searchInputTarget.value.trim().toLowerCase()
    let anyVisible = false

    this.element.querySelectorAll('.dropdown-menu__list a, .dropdown-menu__list button').forEach((item) => {
      const text = item.dataset.filterText ?? item.textContent
      const match = query === '' || text.replace(/\s+/g, ' ').trim().toLowerCase().includes(query)
      item.hidden = !match
      if (match) anyVisible = true
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = anyVisible || query === ''
  }

  resetFilter() {
    this.searchInputTarget.value = ''
    this.filter()
  }

  handleKeydown(event) {
    // The keydown listener is always attached, so guard against firing when closed.
    if (!this.element.matches(':popover-open')) return

    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowUp': {
        const items = this.focusableItems
        if (items.length === 0) return

        event.preventDefault()
        const idx = items.indexOf(document.activeElement)
        if (event.key === 'ArrowDown') items[idx < items.length - 1 ? idx + 1 : 0].focus()
        else items[idx > 0 ? idx - 1 : items.length - 1].focus()
        break
      }
      case 'Escape':
        // Close on Escape ourselves. Native popover light-dismiss is unreliable
        // here because other document-level keydown handlers (e.g. the index-row
        // navigator) can consume Escape first. stopPropagation keeps them from
        // also reacting; hidePopover restores focus to the trigger.
        event.preventDefault()
        event.stopPropagation()
        // With a non-empty search query the first Escape only clears it; the next closes.
        if (this.hasSearchInputTarget && this.searchInputTarget.value !== '') {
          this.resetFilter()
          this.searchInputTarget.focus()
        } else {
          this.element.hidePopover()
        }
        break
      default:
    }
  }
}
