import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

// Drag-to-resize for the desktop sidebar (Units 5-7).
//
// This controller is the SINGLE owner of the handle's `hidden` attribute. The
// partial always renders it hidden, so a no-JS visit leaves an inert element:
// no orphaned tab stop, no strip eating content clicks.
//
// 64rem rather than a hardcoded 1024 (which sidebar_controller.js does, and
// which diverges the moment a host raises the root font size) — it matches
// layout.css's --breakpoint-lg gate on the width derivation.
const DESKTOP_MEDIA_QUERY = '(min-width: 64rem)'

// Travel before a press becomes a drag. Below this, a click in the strip must
// leave no trace at all — see the `armed` state in startDrag.
const DRAG_THRESHOLD = 3

// CSS hook only. Cross-controller state goes through the public isDragging
// getter, never through this attribute.
const RESIZING_ATTRIBUTE = 'data-sidebar-resizing'

const STORED_PROPERTY = '--sidebar-width-stored'

export default class extends Controller {
  connect() {
    this.pointerId = null
    this.frame = null
    this.dragging = false

    this.mediaQuery = window.matchMedia(DESKTOP_MEDIA_QUERY)
    this.refresh = this.refresh.bind(this)
    this.clearResizingState = this.clearResizingState.bind(this)
    // Escape and window blur are document/window level on purpose: a drag does
    // not require the handle to be focused, so an element listener would miss
    // both.
    this.onDocumentKeydown = this.onDocumentKeydown.bind(this)
    this.onWindowBlur = this.onWindowBlur.bind(this)
    this.drag = this.drag.bind(this)
    this.endDrag = this.endDrag.bind(this)

    this.mediaQuery.addEventListener('change', this.refresh)
    document.addEventListener('turbo:load', this.clearResizingState)
    document.addEventListener('keydown', this.onDocumentKeydown)
    window.addEventListener('blur', this.onWindowBlur)

    this.clearResizingState()
    this.refresh()
  }

  disconnect() {
    this.mediaQuery.removeEventListener('change', this.refresh)
    document.removeEventListener('turbo:load', this.clearResizingState)
    document.removeEventListener('keydown', this.onDocumentKeydown)
    window.removeEventListener('blur', this.onWindowBlur)

    // disconnect fires on every Turbo navigation, so this is the abort path that
    // actually runs most often.
    this.abortDrag()
    this.clearResizingState()
  }

  // Public. sidebar_controller and global_hotkeys ask through
  // getControllerForElementAndIdentifier rather than reading the <html>
  // attribute, which stays a CSS hook.
  get isDragging() {
    return this.dragging
  }

  // Public. Unit 9 calls this from sidebar_controller when the sidebar toggles.
  refresh() {
    this.element.hidden = !(this.mediaQuery.matches && this.sidebarIsOpen)
  }

  // -- drag ----------------------------------------------------------------

  startDrag(event) {
    if (event.button !== 0 || !event.isPrimary) return

    this.pointerId = event.pointerId
    this.startX = event.clientX
    this.cancelled = false

    // Read the baseline from RENDERED geometry, never from the stored value.
    // When the viewport clamp is active (a stored 480 renders 409.6 at 1024px) a
    // stored baseline would make the first ~70px of travel a dead zone and the
    // edge would detach from the cursor.
    this.startWidth = this.sidebarElement.getBoundingClientRect().width
    this.latestWidth = this.startWidth

    // Verbatim so Escape can restore "no stored preference" as absence rather
    // than writing the default back as an explicit value.
    this.initialStoredValue = document.documentElement.style.getPropertyValue(STORED_PROPERTY)

    // The move/up listeners live on `window`, NOT on the handle, and that is
    // load-bearing: pointer capture is supposed to retarget them here, but it
    // does not hold under CDP-synthesized input (verified — hasPointerCapture
    // reports true while every move still targets whatever is under the
    // cursor). Binding to window makes the drag independent of whether capture
    // works at all. Capture is still requested because it does help real input.
    window.addEventListener('pointermove', this.drag)
    window.addEventListener('pointerup', this.endDrag)
    window.addEventListener('pointercancel', this.endDrag)

    try {
      this.element.setPointerCapture(event.pointerId)
    } catch {
      // Throws NotFoundError when the id no longer matches an active pointer.
      // Nothing depends on it succeeding.
    }
  }

  drag(event) {
    if (this.pointerId === null || event.pointerId !== this.pointerId) return

    // Armed, not yet dragging. Committing at pointerdown would make every
    // incidental click in the strip flash the global cursor, suppress every
    // transition and reveal the grip — on a path the pointer crosses constantly.
    if (!this.dragging) {
      if (Math.abs(event.clientX - this.startX) < DRAG_THRESHOLD) return

      this.dragging = true
      document.documentElement.setAttribute(RESIZING_ATTRIBUTE, '')
    }

    this.pointerX = event.clientX
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.applyWidth(this.widthForPointer(this.pointerX))
    })
  }

  endDrag(event) {
    if (this.pointerId === null) return
    if (event?.pointerId !== undefined && event.pointerId !== this.pointerId) return

    const wasDragging = this.dragging
    const reverting = this.cancelled

    this.stopTracking()

    if (!wasDragging) return // a click, not a drag: leave width and cookie alone

    if (reverting) {
      // Escape is the only revert path (every other termination commits, per
      // R7). Restore the pre-drag value verbatim and persist nothing.
      this.writeStoredProperty(this.initialStoredValue)
      delete this.element.dataset.atBound
      document.documentElement.removeAttribute(RESIZING_ATTRIBUTE)
      return
    }

    // Order matters. Removing the attribute in the same task as the final write
    // lets the browser coalesce both and animate the restored
    // `transition: width 0.1s` from the pre-drag value — exactly the snap a 1:1
    // drag must not have.
    this.applyWidth(this.latestWidth)
    this.sidebarElement.offsetHeight // eslint-disable-line no-unused-expressions
    document.documentElement.removeAttribute(RESIZING_ATTRIBUTE)

    this.persist(this.latestWidth)
    this.element.setAttribute('aria-valuenow', Math.round(this.latestWidth))
  }

  // Double-click resets to the default (R6).
  reset(event) {
    event.preventDefault()

    // The gesture is pointerdown/up/click twice before dblclick, so both pointer
    // pairs already ran the drag machinery. Cancel anything still pending or a
    // late write re-pins the width this just cleared.
    this.abortDrag()

    // Attribute off BEFORE the property is cleared, so the restored 0.1s width
    // transition animates the return. Otherwise the reset is indistinguishable
    // from nothing having happened — and at the default it produces no
    // response at all.
    document.documentElement.removeAttribute(RESIZING_ATTRIBUTE)
    document.documentElement.style.removeProperty(STORED_PROPERTY)
    Cookies.remove(this.cookieKey, { path: '/' })
    this.persistFailed = false

    delete this.element.dataset.atBound
    this.element.setAttribute('aria-valuenow', Math.round(this.defaultWidth))
  }

  // -- geometry ------------------------------------------------------------

  widthForPointer(clientX) {
    // The sidebar sits at the inline start, so in LTR moving toward the content
    // (clientX up) widens it and in RTL the sign flips.
    const delta = this.isRtl ? this.startX - clientX : clientX - this.startX

    return Math.min(Math.max(this.startWidth + delta, this.minWidth), this.maxWidth)
  }

  applyWidth(width) {
    this.latestWidth = width
    this.writeStoredProperty(`${width}px`)
    this.updateBoundState(width)
  }

  // At-bound feedback. Without it the pointer keeps travelling while the edge
  // stays still with no cue in any modality, and the widget is indistinguishable
  // from a broken one.
  updateBoundState(width) {
    if (width <= this.minWidth) {
      this.element.dataset.atBound = 'min'
    } else if (width >= this.maxWidth) {
      this.element.dataset.atBound = 'max'
    } else {
      delete this.element.dataset.atBound
    }
  }

  get minWidth() {
    return window.Avo.configuration.sidebar.widthMin
  }

  // Mirrors the CSS `min(480px, 40vw)` exactly. A JS-only 480 would pin the drag
  // at a width the layout never renders, and make aria-valuemax a lie.
  get maxWidth() {
    return Math.min(window.Avo.configuration.sidebar.widthMax, 0.4 * window.innerWidth)
  }

  // The width the sidebar starts at with no stored preference — Avo's 256px
  // unless the host set Avo.configuration.sidebar[:default_width]. This is what
  // remove-when-default compares against, so reading it from config rather than
  // hardcoding 256 is what keeps a configured host from accumulating a cookie
  // that merely restates their own default.
  get defaultWidth() {
    return window.Avo.configuration.sidebar.widthDefault
  }

  get isRtl() {
    return getComputedStyle(this.element).direction === 'rtl'
  }

  get sidebarElement() {
    return document.querySelector('#main-sidebar .avo-sidebar')
  }

  get sidebarIsOpen() {
    return this.element.closest('[data-controller~="sidebar"]')?.dataset.sidebarOpenValue === 'true'
  }

  // -- persistence ---------------------------------------------------------

  get cookieKey() {
    return `${window.Avo.configuration.cookies_key}.sidebar.width`
  }

  // Synchronous on drag end, never debounced: a debounce lets a release followed
  // immediately by a sidebar-link click read back the stale value and revert the
  // width the user just chose.
  persist(width) {
    const value = String(Math.round(width))

    // Remove-when-default at every write site. Writing "256" would create a
    // long-lived cookie indistinguishable from a deliberate preference, which
    // would survive any future change to the product default.
    if (value === String(Math.round(this.defaultWidth))) {
      Cookies.remove(this.cookieKey, { path: '/' })
      this.persistFailed = false
      return
    }

    Cookies.set(this.cookieKey, value, {
      expires: 365,
      path: '/',
      sameSite: 'lax',
      secure: window.location.protocol === 'https:',
    })

    // Read back. A blocked jar, a full jar, cross-site framing and Safari's ITP
    // 7-day cap all fail silently, and treating the cookie as sole authority
    // would then revert the user's width on their next click. Unit 3's sync
    // skips its removeProperty branch while this is set.
    this.persistFailed = Cookies.get(this.cookieKey) !== value
  }

  // -- lifecycle -----------------------------------------------------------

  onDocumentKeydown(event) {
    if (event.key !== 'Escape' || this.pointerId === null) return

    event.preventDefault()
    this.cancelled = true
    this.endDrag()
  }

  // Not in the Pointer Events spec's guaranteed suppression list, so it needs
  // handling of its own.
  onWindowBlur() {
    this.endDrag()
  }

  abortDrag() {
    this.stopTracking()
  }

  stopTracking() {
    window.removeEventListener('pointermove', this.drag)
    window.removeEventListener('pointerup', this.endDrag)
    window.removeEventListener('pointercancel', this.endDrag)

    this.cancelFrame()
    this.releaseCapture()
    this.pointerId = null
    this.dragging = false
  }

  cancelFrame() {
    if (!this.frame) return

    cancelAnimationFrame(this.frame)
    this.frame = null
  }

  releaseCapture() {
    if (this.pointerId === null) return

    try {
      this.element.releasePointerCapture(this.pointerId)
    } catch {
      // Already released — every termination path funnels through here.
    }
  }

  writeStoredProperty(value) {
    if (value) {
      document.documentElement.style.setProperty(STORED_PROPERTY, value)
    } else {
      document.documentElement.style.removeProperty(STORED_PROPERTY)
    }
  }

  // Unconditional backstop. A drag aborted through a path nobody anticipated
  // would otherwise leave the whole document with col-resize, no text selection
  // and no layout transitions until the next full load. Running it on connect
  // and on turbo:load means any navigation self-heals.
  clearResizingState() {
    document.documentElement.removeAttribute(RESIZING_ATTRIBUTE)
  }
}
