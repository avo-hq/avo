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
    // Turbo fires NO `turbo:frame-load` on failure, so completion hooks alone
    // wouldn't cover errors. We bind the two failure events Turbo emits on this
    // frame and render the inline error state ourselves:
    //   - `turbo:fetch-request-error`: network failure / timeout (no response).
    //   - `turbo:before-fetch-response`: a response arrived; if it's not OK
    //     (status >= 400 — 4xx/5xx) we treat it as a failure and stop Turbo
    //     from rendering the error body into the frame.
    // Both listeners are scoped to `this.element` (the frame), so we only react
    // to fetch responses for THIS frame.
    this.onRequestError = this.handleRequestError.bind(this)
    this.onBeforeFetchResponse = this.handleBeforeFetchResponse.bind(this)

    this.element.addEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.addEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
  }

  disconnect() {
    this.element.removeEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.removeEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
  }

  // Click handler for the Load (and, via `retry`, Retry) button.
  load() {
    // `pending` scopes our failure handling to THIS deferred load. Once the
    // content loads successfully, the loaded markup may itself navigate the
    // frame (e.g. association pagination); we must not intercept those.
    this.pending = true
    this.showLoading()
    // Setting `src` triggers Turbo to fetch and swap in the deferred content.
    this.element.src = this.urlValue
  }

  // Click handler for the Retry button: drop the error state and re-issue the
  // request. `load()` re-shows the loading spinner and re-sets `src`.
  retry() {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.add('hidden')
    }

    this.load()
  }

  // Swap the placeholder for the loading spinner and mark the frame busy so
  // assistive tech announces the in-flight state.
  showLoading() {
    this.element.setAttribute('aria-busy', 'true')

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.add('hidden')
    }

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
  }

  // --- Failure handling -----------------------------------------------------

  // Network failure / timeout (no HTTP response at all).
  handleRequestError() {
    // Only react to a failure of our own deferred load, not to later
    // navigations inside the loaded content.
    if (!this.pending) return

    this.pending = false
    this.showError()
  }

  // A response arrived. If it's not OK (status >= 400), stop Turbo from
  // rendering the error body into the frame and show our inline error instead.
  handleBeforeFetchResponse(event) {
    // Ignore navigations that happen after our deferred load resolved (e.g. the
    // loaded content paginating itself) — those are Turbo's to handle.
    if (!this.pending) return

    const response = event.detail?.fetchResponse?.response

    // No response object — let other handlers deal with it.
    if (!response) return

    // 2xx/3xx: our deferred load succeeded. Stop intercepting and let Turbo swap
    // the content in.
    if (response.ok) {
      this.pending = false
      return
    }

    // 4xx/5xx: prevent Turbo from rendering the failure body into the frame and
    // show the inline error + Retry instead.
    this.pending = false
    event.preventDefault()
    this.showError()
  }

  // Swap the loading spinner for the inline error state and clear `aria-busy`.
  showError() {
    this.element.removeAttribute('aria-busy')

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
