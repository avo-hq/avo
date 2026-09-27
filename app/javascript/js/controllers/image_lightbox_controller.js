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
 *
 * Registered as `image-lightbox`: avo-ai registers a `lightbox` controller of its own on the
 * same Stimulus application, and the last registration of an identifier wins.
 */
export default class extends Controller {
  static targets = ['dialog', 'item', 'image', 'caption', 'counter', 'original', 'prev', 'next']

  connect() {
    this.index = 0
    this.pointerDownOnDialog = false
    this.handleKeydown = this.handleKeydown.bind(this)
    this.close = this.close.bind(this)
    // A dialog left open would be snapshotted open.
    document.addEventListener('turbo:before-cache', this.close)
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.close)

    // Stimulus has already unbound the dialog's `close` action by now, so tear down by hand.
    if (this.hasDialogTarget && this.dialogTarget.open) {
      this.dialogTarget.close()
      this.closed()
    }
  }

  open(event) {
    event.preventDefault()
    this.show(this.itemTargets.indexOf(event.currentTarget))

    if (this.dialogTarget.open) return

    this.dialogTarget.showModal()
    // showModal() sets neither: the body class is what the global hotkeys and the index row
    // navigator check before acting, and what locks the page's scroll (see base_modal_controller).
    document.body.classList.add('modal-open')
    // On the document rather than the dialog: a click on the image moves focus to <body>, and
    // key events then never reach a listener on the dialog.
    document.addEventListener('keydown', this.handleKeydown)
  }

  close() {
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  // The dialog's `close` event, whether from #close, Escape or the browser.
  closed() {
    document.body.classList.remove('modal-open')
    document.removeEventListener('keydown', this.handleKeydown)
  }

  // A press that starts on the image and is released over the backdrop dispatches its click to
  // their common ancestor, the dialog. Remember where the press started so only a click that
  // both began and ended on the dialog's own area closes it.
  trackPointerDown(event) {
    this.pointerDownOnDialog = event.target === this.dialogTarget
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget && this.pointerDownOnDialog) this.close()
    this.pointerDownOnDialog = false
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
      imageLightboxSrcParam: src,
      imageLightboxTitleParam: title = '',
      imageLightboxOriginalParam: original,
    } = items[this.index].dataset

    this.imageTarget.src = src
    this.imageTarget.alt = title
    // No title (the field hides filenames) means no caption either.
    this.captionTarget.textContent = title
    this.captionTarget.title = title
    this.captionTarget.hidden = !title
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
