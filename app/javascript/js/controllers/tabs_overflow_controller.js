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
    this.update()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
  }

  update() {
    // Drop the modifier so we can measure the natural (wrapping) layout.
    this.element.classList.remove(MODIFIER_CLASS)

    const items = Array.from(this.element.children)
    if (items.length < 2) return

    const firstTop = items[0].offsetTop
    const wraps = items.some((item) => item.offsetTop !== firstTop)

    this.element.classList.toggle(MODIFIER_CLASS, wraps)
  }
}
