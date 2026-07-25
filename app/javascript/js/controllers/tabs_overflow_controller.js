import { Controller } from '@hotwired/stimulus'

const MODIFIER_CLASS = 'tabs--scrollable'

// Detects when the tabs would wrap onto more than one row and toggles the
// `tabs--scrollable` modifier so they collapse to a single, horizontally
// scrollable row instead.
export default class extends Controller {
  connect() {
    this.update = this.update.bind(this)
    this.resizeObserver = new ResizeObserver(this.update)
    this.resizeObserver.observe(this.element)

    // Capture scroll position as the user scrolls, so we have it ready
    // when update() runs (by then, the browser may have already reset it).
    this.lastScrollLeft = this.element.scrollLeft
    this.handleScroll = this.handleScroll.bind(this)
    this.element.addEventListener('scroll', this.handleScroll)

    this.update()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    this.element.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    this.lastScrollLeft = this.element.scrollLeft
  }

  update() {
    // Drop the modifier so we can measure the natural (wrapping) layout.
    this.element.classList.remove(MODIFIER_CLASS)

    const items = Array.from(this.element.children)
    if (items.length < 2) return

    const firstTop = items[0].offsetTop
    const wraps = items.some((item) => item.offsetTop !== firstTop)

    this.element.classList.toggle(MODIFIER_CLASS, wraps)

    // Restore the scroll position after re-applying the scrollable class.
    // Use the last captured scroll position from handleScroll, since the
    // browser may have already reset scrollLeft by the time update() runs.
    this.element.scrollLeft = this.lastScrollLeft ?? 0
  }
}
