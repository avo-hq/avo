import { Controller } from '@hotwired/stimulus'

/**
 * In-page lightbox for the images of a file / files field, rendered once per gallery by
 * Avo::LightboxComponent as a native <dialog>.
 *
 * Every thumbnail is an `item` target carrying the image it opens as action params (`src`,
 * `title`, `original`). Opening shows that image; prev/next and the arrow keys walk the items in
 * DOM order and wrap around. Escape is the dialog's own — it fires `close`, which #closed
 * listens to — and a click on the dialog's empty area (off the image and its controls) closes
 * as well.
 */
export default class extends Controller {
  static targets = ['dialog', 'item', 'image', 'caption', 'counter', 'original', 'prev', 'next']

  connect() {
    this.index = 0
    this.handleKeydown = this.handleKeydown.bind(this)
    this.close = this.close.bind(this)
    // A dialog left open would be snapshotted open.
    document.addEventListener('turbo:before-cache', this.close)
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.close)
    document.removeEventListener('keydown', this.handleKeydown)
  }

  open(event) {
    event.preventDefault()
    this.show(this.itemTargets.indexOf(event.currentTarget))

    if (this.dialogTarget.open) return

    this.dialogTarget.showModal()
    // On the document rather than the dialog: a click on the image moves focus to <body>, and
    // key events then never reach a listener on the dialog.
    document.addEventListener('keydown', this.handleKeydown)
  }

  close() {
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  // The dialog's `close` event, whether from #close, Escape or the browser.
  closed() {
    document.removeEventListener('keydown', this.handleKeydown)
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  next() {
    this.show(this.index + 1)
  }

  prev() {
    this.show(this.index - 1)
  }

  handleKeydown(event) {
    if (!this.dialogTarget.open || event.defaultPrevented) return

    // The arrows follow the reading direction: "back" is the arrow pointing at the prev button.
    const rtl = getComputedStyle(this.dialogTarget).direction === 'rtl'
    const back = rtl ? 'ArrowRight' : 'ArrowLeft'
    const forward = rtl ? 'ArrowLeft' : 'ArrowRight'

    if (event.key === back) {
      event.preventDefault()
      this.prev()
    } else if (event.key === forward) {
      event.preventDefault()
      this.next()
    }
  }

  show(index) {
    const items = this.itemTargets
    if (items.length === 0) return

    this.index = (index + items.length) % items.length
    const {
      lightboxSrcParam: src,
      lightboxTitleParam: title = '',
      lightboxOriginalParam: original,
    } = items[this.index].dataset

    this.imageTarget.src = src
    this.imageTarget.alt = title
    this.captionTarget.textContent = title
    this.counterTarget.textContent = `${this.index + 1} / ${items.length}`

    // Nothing to cycle through with a single image.
    const single = items.length < 2
    this.prevTarget.hidden = single
    this.nextTarget.hidden = single
    this.counterTarget.hidden = single

    // The original is linked only when the item names one (the user may download the file).
    if (original) {
      this.originalTarget.href = original
      this.originalTarget.hidden = false
    } else {
      this.originalTarget.removeAttribute('href')
      this.originalTarget.hidden = true
    }
  }
}
