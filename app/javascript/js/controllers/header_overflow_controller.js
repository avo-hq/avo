import { Controller } from '@hotwired/stimulus'

// Minimum slot width (px) for a truncated tail item. Below this the visible
// portion shrinks to just "…", which reads as a glitch — so we push the
// item into the dropdown instead.
const MIN_TRUNCATED_WIDTH = 32

export default class extends Controller {
  static targets = ['row', 'trigger']

  connect() {
    this.items = Array.from(this.rowTarget.children)

    this.scheduleUpdate = this.scheduleUpdate.bind(this)
    this.resizeObserver = new ResizeObserver(this.scheduleUpdate)
    this.resizeObserver.observe(this.element)
    this.bindAriaExpanded()
    this.update()
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    if (this.rafId) cancelAnimationFrame(this.rafId)
    if (this.popoverElement && this.handlePopoverToggle) {
      this.popoverElement.removeEventListener('toggle', this.handlePopoverToggle)
    }
  }

  bindAriaExpanded() {
    if (!this.hasTriggerTarget) return
    const popoverId = this.triggerTarget.getAttribute('popovertarget')
    this.popoverElement = popoverId ? document.getElementById(popoverId) : null
    if (!this.popoverElement) return
    this.handlePopoverToggle = (event) => {
      this.triggerTarget.setAttribute('aria-expanded', event.newState === 'open' ? 'true' : 'false')
    }
    this.popoverElement.addEventListener('toggle', this.handlePopoverToggle)
  }

  scheduleUpdate() {
    if (this.rafId) return
    this.rafId = requestAnimationFrame(() => {
      this.rafId = null
      this.update()
    })
  }

  update() {
    if (this.items.length === 0) {
      this.element.classList.remove('header-overflow--has-overflow')
      this.element.classList.remove('header-overflow--row-empty')
      this.element.classList.add('header-overflow--empty')
      return
    }
    this.element.classList.remove('header-overflow--empty')

    // Unhide everything so measurements reflect natural widths.
    this.items.forEach((item) => {
      item.style.display = ''
    })
    if (this.truncatedItem) {
      this.truncatedItem.classList.remove('header-overflow__item--truncated')
      this.truncatedItem.style.maxWidth = ''
      this.truncatedItem = null
    }

    const triggerWidth = this.hasTriggerTarget ? this.triggerTarget.offsetWidth : 0

    const available = this.element.clientWidth
    const rowStyle = window.getComputedStyle(this.rowTarget)
    const gap = parseFloat(rowStyle.columnGap) || parseFloat(rowStyle.gap) || 0

    let firstOverflowIndex = this.items.length
    let used = 0
    for (let i = 0; i < this.items.length; i += 1) {
      const next = used + (i === 0 ? 0 : gap) + this.items[i].offsetWidth
      const willOverflow = i < this.items.length - 1
      const budget = willOverflow ? available - triggerWidth - gap : available
      if (next > budget) {
        firstOverflowIndex = i
        break
      }
      used = next
    }

    let truncatedIndex = -1
    if (firstOverflowIndex < this.items.length) {
      const prefixWidth = used + (firstOverflowIndex > 0 ? gap : 0)
      const leftover = available - triggerWidth - gap - prefixWidth
      if (leftover >= MIN_TRUNCATED_WIDTH) {
        truncatedIndex = firstOverflowIndex
        this.truncatedItem = this.items[truncatedIndex]
        this.truncatedItem.classList.add('header-overflow__item--truncated')
        this.truncatedItem.style.maxWidth = `${Math.floor(leftover)}px`
      }
    }

    const hiddenStart = firstOverflowIndex + (truncatedIndex >= 0 ? 1 : 0)
    for (let i = hiddenStart; i < this.items.length; i += 1) {
      this.items[i].style.display = 'none'
    }

    const hasOverflow = firstOverflowIndex < this.items.length
    this.element.classList.toggle('header-overflow--has-overflow', hasOverflow)
    const rowHasItems = firstOverflowIndex > 0 || truncatedIndex >= 0
    this.element.classList.toggle('header-overflow--row-empty', !rowHasItems)
  }
}
