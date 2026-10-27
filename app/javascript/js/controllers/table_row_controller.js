import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  anchor = null

  mouseEntered(event) {
    const row = event.target.closest('[data-visit-path]')
    const url = row?.dataset?.visitPath

    if (url) {
      this.anchor = this.createAnchor(url)
      this.anchor.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }))
    }
  }

  mouseLeft() {
    if (this.anchor) {
      this.anchor.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }))
      document.body.removeChild(this.anchor)
    }
  }

  createAnchor(url) {
    const anchor = document.createElement('a')
    anchor.href = url
    anchor.rel = 'noopener noreferrer'
    document.body.appendChild(anchor)

    return anchor
  }

  visitRecord(event) {
    const isMiddleClick = event.type === 'auxclick' && event.button === 1

    if (event.type !== 'click' && !isMiddleClick) {
      return
    }

    if (window.getSelection().toString().length > 0) {
      return
    }

    // We won't navigate if shift is pressed. That is usually used to select multiple rows.
    const isShiftPressed = event.shiftKey
    // We won't navigate if the user clicks on the item selector cell
    const isItemSelector = event.target.closest('.item-selector-cell')
    // Leave links and form controls to their own handlers and native browser behavior.
    const isInteractive = event.target.closest('a, button, input, select, textarea, label, [contenteditable]')

    if (isShiftPressed || isInteractive || isItemSelector) {
      return
    }

    const row = event.target.closest('[data-visit-path]')
    const url = row?.dataset?.visitPath

    if (!row || !url) {
      return
    }

    if (isMiddleClick || event.metaKey || event.ctrlKey || row.dataset.visitTarget === '_blank') {
      event.preventDefault()
      this.#visitInNewTab(url)
    } else {
      this.#visitInSameTab(url)
    }
  }

  #visitInSameTab(url) {
    window.Turbo.visit(url)
  }

  #visitInNewTab(url) {
    window.open(url, '_blank', 'noopener,noreferrer')
  }
}
