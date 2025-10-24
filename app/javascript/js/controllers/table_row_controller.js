import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.isSelecting = false
    this.#bindSelectionEvents()
  }

  // add another timer which starts on this method and stops on mouseleft method
  mouseLeftTimer = null

  startMouseLeftTimer() {
    this.mouseLeftTimer = performance.now()
  }

  stopMouseLeftTimer() {
    this.mouseLeftTimer = performance.now() - this.mouseLeftTimer
    console.log('time taken', this.mouseLeftTimer, 'milliseconds')
  }

  mouseEntered(event) {
    this.startMouseLeftTimer()
    // add timer to this method and console log the time it took to execute
    const startTime = performance.now()
    // console.log('mouseEntered', event.target)
    // const isLink = event.target.closest('a')
    const row = event.target.closest('tr')
    const url = row.dataset.visitPath

    if (url) {
      console.log('is link', window.Turbolinks.session.linkPrefetchObserver, url)
      const anchor = this.createAnchor(url)
      console.log('anchor', anchor)
      // # simulate a hover event on the anchor
      anchor.dispatchEvent(new MouseEvent('mouseenter', { bubbles: true }))
      // setTimeout(() => {
      //   anchor.dispatchEvent(new MouseEvent('mouseleave', { bubbles: true }))
      // }, 100)
      // console.log('t', t)
    }
    // are these seconds or milliseconds?
    const timeTaken = performance.now() - startTime
    console.log('time taken', timeTaken, 'milliseconds')
  }

  mouseLeft(event) {
    console.log('mouseLeft', event.target)
    this.stopMouseLeftTimer()
  }

  createAnchor(url) {
    const anchor = document.createElement('a')
    anchor.href = url
    anchor.rel = 'noopener noreferrer'
    document.body.appendChild(anchor)

    return anchor
  }

  visitRecord(event) {
    if (event.type !== 'click') {
      return
    }

    if (this.#isTextSelected()) {
      return
    }

    // We won't navigate if shift is pressed. That is usually used to select multiple rows.
    const isShiftPressed = event.shiftKey
    // We won't navigate if the user clicks on the item selector cell
    const isItemSelector = event.target.closest('.item-selector-cell')
    // We won't navigate if the user clicks on a link or button
    const isLinkOrButton = event.target.closest('a, button')
    // We won't navigate if the user clicks on a checkbox
    const isCheckbox = event.target.closest('input[type="checkbox"]')

    if (isShiftPressed || isLinkOrButton || isCheckbox || isItemSelector) {
      return // Don't navigate if a link or button is clicked
    }

    const row = event.target.closest('tr')
    const url = row.dataset.visitPath

    if (!row || !url) {
      return
    }

    if (event.metaKey || event.ctrlKey) {
      this.#visitInNewTab(url)
    } else {
      this.#visitInSameTab(url)
    }
  }

  #bindSelectionEvents() {
    this.element.addEventListener('mousedown', this.#handleMouseDown.bind(this))
    this.element.addEventListener('mousemove', this.#handleMouseMove.bind(this))
  }

  #handleMouseDown() {
    this.isSelecting = false
  }

  #handleMouseMove(event) {
    if (event.buttons === 1) { // Left mouse button is being held
      this.isSelecting = true
    }
  }

  #isTextSelected() {
    if (this.isSelecting || window.getSelection().toString().length > 0) {
      this.isSelecting = false

      return true
    }

    return false
  }

  #visitInSameTab(url) {
    window.Turbo.visit(url)
  }

  #visitInNewTab(url) {
    window.open(url, '_blank').focus()
  }
}
