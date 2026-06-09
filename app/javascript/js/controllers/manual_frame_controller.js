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
  static targets = ['placeholder', 'loading']

  static values = {
    url: String,
  }

  // Click handler for the Load (and, in Unit 5, Retry) button.
  load() {
    this.showLoading()
    // Setting `src` triggers Turbo to fetch and swap in the deferred content.
    this.element.src = this.urlValue
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

  // --- Failure handling seam (Unit 5) ---------------------------------------
  // Unit 5 binds the failure events Turbo emits on this frame
  // (`turbo:fetch-request-error` for network/timeout and
  // `turbo:before-fetch-response` for non-2xx responses) and renders an inline
  // error + Retry state here. The `retry` action will re-issue the request by
  // calling `load()` again. Not implemented in this unit on purpose.
}
