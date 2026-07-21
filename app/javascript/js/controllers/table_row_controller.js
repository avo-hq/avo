import { Controller } from '@hotwired/stimulus'

// Bound on <tbody>, not <tr>. Stimulus actions on table rows are unreliable
// across browsers; event delegation from the body avoids that entirely.
export default class extends Controller {
  static DRAG_THRESHOLD_PX = 5

  connect() {
    this.isSelecting = false
    this.mouseDownX = 0
    this.mouseDownY = 0
    this.currentPrefetchRow = null
    this.anchor = null

    this.boundHandleMouseDown = this.#handleMouseDown.bind(this)
    this.boundHandleMouseMove = this.#handleMouseMove.bind(this)
    this.element.addEventListener('mousedown', this.boundHandleMouseDown)
    this.element.addEventListener('mousemove', this.boundHandleMouseMove)
  }

  disconnect() {
    this.element.removeEventListener('mousedown', this.boundHandleMouseDown)
    this.element.removeEventListener('mousemove', this.boundHandleMouseMove)
    this.#clearPrefetchAnchor()
  }

  // mouseover (bubbles) — used instead of mouseenter so tbody can delegate.
  mouseEntered(event) {
    const row = event.target.closest('tr[data-visit-path]')
    if (!row || !this.element.contains(row)) return
    if (row === this.currentPrefetchRow) return

    this.#clearPrefetchAnchor()
    this.currentPrefetchRow = row

    const url = row.dataset.visitPath
    if (!url) return

    this.anchor = this.#createAnchor(url)
    this.anchor.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }))
  }

  // mouseout (bubbles) — ignore moves that stay inside the same row.
  mouseLeft(event) {
    const row = event.target.closest('tr[data-visit-path]')
    if (!row || row !== this.currentPrefetchRow) return

    const relatedRow = event.relatedTarget?.closest?.('tr[data-visit-path]')
    if (relatedRow === row) return

    this.#clearPrefetchAnchor()
  }

  visitRecord(event) {
    if (event.type !== 'click') return

    const row = event.target.closest('tr[data-visit-path]')
    if (!row || !this.element.contains(row)) return

    if (this.#shouldSkipNavigation(event, row)) return

    const url = row.dataset.visitPath
    if (!url) return

    if (event.metaKey || event.ctrlKey) {
      this.#visitInNewTab(url)
    } else {
      this.#visitInSameTab(url)
    }
  }

  #shouldSkipNavigation(event, row) {
    if (this.#isTextSelected(row)) return true
    if (event.shiftKey) return true
    if (event.target.closest('.item-selector-cell')) return true
    if (event.target.closest('a, button')) return true
    if (event.target.closest('input[type="checkbox"]')) return true

    return false
  }

  #handleMouseDown(event) {
    this.isSelecting = false
    this.mouseDownX = event.clientX
    this.mouseDownY = event.clientY
  }

  #handleMouseMove(event) {
    if (event.buttons !== 1 || this.isSelecting) return

    const dx = Math.abs(event.clientX - this.mouseDownX)
    const dy = Math.abs(event.clientY - this.mouseDownY)
    if (dx > this.constructor.DRAG_THRESHOLD_PX || dy > this.constructor.DRAG_THRESHOLD_PX) {
      this.isSelecting = true
    }
  }

  #isTextSelected(row) {
    if (this.isSelecting) {
      this.isSelecting = false

      return true
    }

    const selection = window.getSelection()
    if (!selection || selection.isCollapsed || selection.toString().length === 0) {
      return false
    }

    // Only block navigation when the selection intersects the clicked row.
    // Leftover selections elsewhere on the page must not swallow clicks.
    if (typeof selection.rangeCount === 'number' && selection.rangeCount > 0) {
      const range = selection.getRangeAt(0)
      if (row.contains(range.commonAncestorContainer)) return true
      // commonAncestorContainer can be a text node
      if (range.commonAncestorContainer.parentElement && row.contains(range.commonAncestorContainer.parentElement)) {
        return true
      }
    }

    return false
  }

  #createAnchor(url) {
    const anchor = document.createElement('a')
    anchor.href = url
    anchor.rel = 'noopener noreferrer'
    document.body.appendChild(anchor)

    return anchor
  }

  #clearPrefetchAnchor() {
    if (this.anchor) {
      this.anchor.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }))
      this.anchor.remove()
      this.anchor = null
    }
    this.currentPrefetchRow = null
  }

  #visitInSameTab(url) {
    window.Turbo.visit(url)
  }

  #visitInNewTab(url) {
    window.open(url, '_blank').focus()
  }
}
