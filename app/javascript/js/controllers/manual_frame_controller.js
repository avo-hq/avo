import { Controller } from '@hotwired/stimulus'

// Drives a manual (on-demand) Turbo Frame: the frame renders with NO `src`,
// and clicking the Load button sets `src` from `data-manual-frame-url-value`
// so the deferred content is fetched only on demand.
//
// The controller is attached to the `<turbo-frame>` element itself, so
// `this.element` is the frame.
//
// Mirrors `select_controller.js` / `fields/panel_refresh_controller.js`, which
// also manipulate the `src` of the frame they live in. We deliberately do NOT
// set `loading="lazy"`, so neither Turbo's lazy auto-fetch nor the #886 strip
// handler touches this frame.
export default class extends Controller {
  static targets = ['placeholder', 'loading', 'error']

  static values = {
    url: String,
  }

  connect() {
    // Turbo fires NO `turbo:frame-load` on failure, so we bind the failure
    // events Turbo emits on this frame and render the inline error ourselves.
    // `pending` scopes ALL of this handling to our own deferred load: once the
    // content has loaded, the loaded markup may itself navigate the frame (e.g.
    // association pagination) — those are Turbo's to handle, so we step aside.
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
    // Ignore repeat clicks while a request is already in flight.
    if (this.pending) return

    this.pending = true
    this.showLoading()

    // Setting `src` triggers Turbo to fetch and swap in the deferred content.
    // On Retry the `src` is already this URL (a failed load leaves it in place),
    // and re-setting an attribute to its current value is a no-op — so reload()
    // to force a fresh fetch in that case.
    if (this.element.getAttribute('src') === this.urlValue) {
      this.element.reload()
    } else {
      this.element.src = this.urlValue
    }
  }

  // Click handler for the Retry button: drop the error state and re-issue.
  retry() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add('hidden')
    }

    this.load()
  }

  // Swap the placeholder for the loading spinner. Turbo owns `aria-busy` on the
  // frame for the duration of the fetch, so we don't manage it here.
  showLoading() {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add('hidden')
    }

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  // --- Lifecycle ------------------------------------------------------------

  // Our deferred load succeeded and Turbo swapped the real content in. Move
  // focus into the frame so keyboard / screen-reader users aren't dropped to
  // <body> when the Load button is removed from the DOM (R9).
  handleFrameLoad() {
    // Not our deferred load (or a later navigation inside loaded content).
    if (!this.pending) return

    this.pending = false
    this.element.setAttribute('tabindex', '-1')
    this.element.focus()
  }

  // Network failure / timeout (no HTTP response at all).
  handleRequestError(event) {
    // A later in-frame navigation failed — let Turbo handle it normally.
    if (!this.pending) return

    this.pending = false
    // Stop the global 500 handler from also acting on our load's failure.
    event.stopImmediatePropagation()
    this.showError()
  }

  // A response arrived. If it's not OK (status >= 400), stop Turbo from
  // rendering the error body into the frame, stop the global `application.js`
  // failure handler from hijacking it, and show our inline error instead.
  handleBeforeFetchResponse(event) {
    // After our load resolves we stop intercepting, so a later in-frame
    // navigation that fails falls through to Turbo / the global handler.
    if (!this.pending) return

    const response = event.detail?.fetchResponse?.response
    if (!response) return

    // 2xx/3xx: success — `handleFrameLoad` finishes the sequence (and clears
    // `pending`) once Turbo renders the content.
    if (response.ok) return

    // 4xx/5xx: show the inline error + Retry.
    this.pending = false
    event.preventDefault()
    event.stopImmediatePropagation()
    this.showError()
  }

  // Swap the loading spinner for the inline error state.
  showError() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add('hidden')
    }

    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove('hidden')
    }
  }
}
