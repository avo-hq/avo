import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
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

    // requestAnimationFrame ensures the popover is fully rendered before we focus.
    // Focusing before the browser paints causes the scroll to jump in some cases.
    requestAnimationFrame(() => {
      const items = this.focusableItems
      if (items.length === 0) return

      // Focus the active item if present (e.g. current per-page selection),
      // otherwise fall back to the first item.
      const active = items.find((el) => el.classList.contains('dropdown-menu__item--active'))
      ;(active || items[0]).focus()
    })
  }

  handleKeydown(event) {
    // The keydown listener is always attached, so guard against firing when closed.
    if (!this.element.matches(':popover-open')) return

    const items = this.focusableItems
    if (items.length === 0) return

    const idx = items.indexOf(document.activeElement)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        items[idx < items.length - 1 ? idx + 1 : 0].focus()
        break
      case 'ArrowUp':
        event.preventDefault()
        items[idx > 0 ? idx - 1 : items.length - 1].focus()
        break
      default:
    }
  }
}
