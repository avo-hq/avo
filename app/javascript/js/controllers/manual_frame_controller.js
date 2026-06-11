import { Controller } from '@hotwired/stimulus'
import { toggleHidden } from '../helpers/toggle_hidden'

// Drives a manual (on-demand) Turbo Frame: the frame renders with NO `src`,
// and clicking the Load button sets `src` from `data-manual-frame-url-value`
// so the deferred content is fetched only on demand.
//
// The controller is attached to the `<turbo-frame>` element itself, so
// `this.element` is the frame.
//
// We deliberately do NOT set `loading="lazy"`, so neither Turbo's lazy
// auto-fetch nor the #886 strip handler touches this frame.
//
// Auto-load memory: when the frame is configured with a window
// (`auto_load_for`), a successful load writes a short-lived cookie. The SERVER
// reads that cookie on the next render and emits a real `<turbo-frame src>`
// (no placeholder, no button) — so the controller never has to "auto-click".
// All this controller does is write/refresh the cookie when the user opens the
// frame; the decision to skip the button lives entirely on the server.
export default class extends Controller {
  static targets = ['placeholder', 'loading', 'error']

  static values = {
    url: String,
    // The cookie name the server reads to decide whether to skip the Load
    // button on the next visit. Empty when the frame has no memory window.
    cookieName: String,
    // Seconds the memory cookie should live (its max-age). 0 (the Stimulus
    // default when the attribute is absent) = no memory.
    autoLoadFor: Number,
  }

  connect() {
    this.pending = false
    this.onRequestError = this.handleRequestError.bind(this)
    this.onBeforeFetchResponse = this.handleBeforeFetchResponse.bind(this)
    this.onFrameLoad = this.handleFrameLoad.bind(this)

    this.element.addEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.addEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
    this.element.addEventListener('turbo:frame-load', this.onFrameLoad)
  }

  disconnect() {
    this.element.removeEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.removeEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
    this.element.removeEventListener('turbo:frame-load', this.onFrameLoad)
  }

  // Click handler for the Load button.
  load() {
    if (this.pending) return // ignore repeat clicks while a request is in flight

    this.pending = true
    this.showLoading()

    // Setting `src` triggers Turbo to fetch and swap in the deferred content.
    // On Retry the `src` is already this URL (a failed load leaves it in place),
    // and re-setting an attribute to its current value is a no-op, so reload()
    // to force a fresh fetch in that case.
    if (this.element.getAttribute('src') === this.urlValue) {
      this.element.reload()
    } else {
      this.element.src = this.urlValue
    }
  }

  // Click handler for the Retry button: drop the error state and re-issue.
  retry() {
    this.load()
  }

  showLoading() {
    this.setHidden(this.placeholderTarget, false)
    this.setHidden(this.loadingTarget, false)
    this.setHidden(this.errorTarget, true)
  }

  showError() {
    this.setHidden(this.placeholderTarget, true)
    this.setHidden(this.loadingTarget, true)
    this.setHidden(this.errorTarget, false)
  }

  setHidden(element, hidden) {
    if (!element) return
    if (element.hasAttribute('hidden') === hidden) return

    toggleHidden(element)
  }

  // --- Lifecycle ------------------------------------------------------------

  // Our deferred load succeeded and Turbo swapped the real content in. Move
  // focus into the frame so keyboard / screen-reader users aren't dropped to
  // <body> when the Load button is removed from the DOM (R9).
  handleFrameLoad() {
    if (!this.pending) return // not our load (or a later navigation inside content)

    this.pending = false

    // Remember the open frame (and slide the window forward) — only on success,
    // so a failed load never sets the memory.
    this.rememberOpen()

    this.element.setAttribute('tabindex', '-1')
    this.element.focus({ preventScroll: true })
  }

  // Network failure / timeout (no HTTP response at all).
  handleRequestError(event) {
    if (!this.pending) return // a later in-frame navigation, let Turbo handle it

    this.pending = false
    event.stopImmediatePropagation()
    this.showError()
  }

  // A response arrived. If it's not OK (status >= 400), stop Turbo from rendering
  // the error body into the frame, stop the global `application.js` handler from
  // hijacking it, and show our inline error instead.
  handleBeforeFetchResponse(event) {
    if (!this.pending) return // after our load resolves, later navigations are Turbo's

    const response = event.detail?.fetchResponse?.response
    if (!response) return

    if (response.ok) return // success: handleFrameLoad finishes the sequence

    this.pending = false
    event.preventDefault()
    event.stopImmediatePropagation()
    this.showError()
  }

  // --- Auto-load memory -----------------------------------------------------

  // Write/refresh the cookie that tells the server "this frame is open, render
  // it without the Load button next time." `max-age` gives it a sliding TTL —
  // the browser drops it when the window lapses, and each successful load
  // rewrites it with a fresh window. No-ops when the frame has no memory window.
  rememberOpen() {
    if (!this.cookieNameValue || this.autoLoadForValue <= 0) return

    document.cookie = `${this.cookieNameValue}=1; path=/; max-age=${this.autoLoadForValue}; samesite=lax`
  }
}
