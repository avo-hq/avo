import { Controller } from '@hotwired/stimulus'

const MODIFIER_CLASS = 'tabs--scrollable'

// Detects when the tabs would wrap onto more than one row and toggles the
// `tabs--scrollable` modifier so they collapse to a single, horizontally
// scrollable row instead.
//
// Each tab panel renders its own copy of the buttons row, so the scroll
// position is shared through the `.tab-group` container: scrolling any row
// stores it, and any row that gets (re)measured restores from it. This keeps
// the row visually still when switching tabs or when lazy frames reflow.
export default class extends Controller {
  connect() {
    this.update = this.update.bind(this)
    this.handleScroll = this.handleScroll.bind(this)
    this.groupElement = this.element.closest('.tab-group')

    // Capture scroll position as the user scrolls, so we have it ready
    // when update() runs (by then, the browser may have already reset it).
    this.lastScrollLeft = this.element.scrollLeft
    this.element.addEventListener('scroll', this.handleScroll, { passive: true })

    this.resizeObserver = new ResizeObserver(this.update)
    this.resizeObserver.observe(this.element)
    this.update()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.element.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    // Ignore scroll resets fired while the row is hidden (display: none).
    if (this.element.clientWidth === 0) return

    this.lastScrollLeft = this.element.scrollLeft

    if (this.groupElement) {
      this.groupElement.dataset.tabsScrollLeft = this.lastScrollLeft
    }
  }

  update() {
    // Prefer the group-stored position so sibling rows stay in sync; fall
    // back to this row's own last known position.
    const scrollLeft = Number(this.groupElement?.dataset.tabsScrollLeft ?? this.lastScrollLeft ?? 0)

    // Drop the modifier so we can measure the natural (wrapping) layout.
    this.element.classList.remove(MODIFIER_CLASS)

    const items = Array.from(this.element.children)
    if (items.length < 2) return

    const firstTop = items[0].offsetTop
    const wraps = items.some((item) => item.offsetTop !== firstTop)

    this.element.classList.toggle(MODIFIER_CLASS, wraps)

    // Restore the scroll position after re-applying the scrollable class —
    // removing it resets the browser's scrollLeft to 0.
    this.element.scrollLeft = scrollLeft
  }
}
