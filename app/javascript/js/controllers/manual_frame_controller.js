import { Controller } from '@hotwired/stimulus'

// Drives a manual (on-demand) Turbo Frame: the frame renders with NO `src`,
// and clicking the Load button sets `src` from `data-manual-frame-url-value`
// so the deferred content is fetched only on demand.
//
// The controller is attached to the `<turbo-frame>` element itself, so
// `this.element` is the frame.
//
// State swaps (placeholder -> loading -> content / error) run inside a View
// Transition so the frame morphs between states. Browsers without the API fall
// back to an instant swap. We deliberately do NOT set `loading="lazy"`, so
// neither Turbo's lazy auto-fetch nor the #886 strip handler touches this frame.
export default class extends Controller {
  static targets = ['placeholder', 'loading', 'error']

  static values = {
    url: String,
  }

  connect() {
    this.pending = false
    this.onRequestError = this.handleRequestError.bind(this)
    this.onBeforeFetchResponse = this.handleBeforeFetchResponse.bind(this)
    this.onBeforeFrameRender = this.handleBeforeFrameRender.bind(this)
    this.onFrameLoad = this.handleFrameLoad.bind(this)

    this.element.addEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.addEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
    this.element.addEventListener('turbo:before-frame-render', this.onBeforeFrameRender)
    this.element.addEventListener('turbo:frame-load', this.onFrameLoad)
  }

  disconnect() {
    this.element.removeEventListener('turbo:fetch-request-error', this.onRequestError)
    this.element.removeEventListener('turbo:before-fetch-response', this.onBeforeFetchResponse)
    this.element.removeEventListener('turbo:before-frame-render', this.onBeforeFrameRender)
    this.element.removeEventListener('turbo:frame-load', this.onFrameLoad)
  }

  // Click handler for the Load button.
  load() {
    if (this.pending) return // ignore repeat clicks while a request is in flight

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
    this.load()
  }

  showLoading() {
    this.morph(() => this.swap('loading'))
  }

  showError() {
    this.morph(() => this.swap('error'))
  }

  // Show exactly one state target, hiding the others.
  swap(name) {
    const targets = { placeholder: this.placeholderTarget, loading: this.loadingTarget, error: this.errorTarget }
    Object.entries(targets).forEach(([n, el]) => {
      if (el) el.classList.toggle('hidden', n !== name)
    })
  }

  // Run a DOM mutation inside a View Transition so the frame morphs. A transient,
  // per-frame `view-transition-name` scopes the morph to this frame; it's cleared
  // when the transition settles so it never collides with other frames or with
  // Turbo's page transitions. No-op wrapper when the API is unavailable.
  morph(mutate) {
    if (!document.startViewTransition) {
      mutate()
      return
    }

    this.element.style.viewTransitionName = this.transitionName
    const transition = document.startViewTransition(() => mutate())
    transition.finished.finally(() => {
      this.element.style.viewTransitionName = ''
    })
  }

  get transitionName() {
    return `manual-frame-${this.element.id || 'frame'}`
  }

  // --- Lifecycle ------------------------------------------------------------

  // Wrap Turbo's render of the loaded content in a View Transition so the
  // content morphs in from the loading state. Only for our own deferred load.
  handleBeforeFrameRender(event) {
    if (!this.pending || !document.startViewTransition) return

    const originalRender = event.detail.render
    event.detail.render = (currentElement, newElement) => {
      this.element.style.viewTransitionName = this.transitionName
      const transition = document.startViewTransition(() => originalRender(currentElement, newElement))
      transition.finished.finally(() => {
        this.element.style.viewTransitionName = ''
      })
    }
  }

  // Our deferred load succeeded and Turbo swapped the real content in. Move
  // focus into the frame so keyboard / screen-reader users aren't dropped to
  // <body> when the Load button is removed from the DOM (R9).
  handleFrameLoad() {
    if (!this.pending) return // not our load (or a later navigation inside content)

    this.pending = false
    this.element.setAttribute('tabindex', '-1')
    this.element.focus()
  }

  // Network failure / timeout (no HTTP response at all).
  handleRequestError(event) {
    if (!this.pending) return // a later in-frame navigation — let Turbo handle it

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
}
