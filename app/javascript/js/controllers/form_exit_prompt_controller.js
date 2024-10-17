import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form']

  connect() {
    this.isDirty = false

    // for select tags
    this.formTarget.addEventListener('change', this.trackChanges.bind(this))
    // for all other input fields
    this.formTarget.addEventListener('input', this.trackChanges.bind(this))

    // in most cases this event will be triggered because Turbo prevents full page reload on navigation
    window.addEventListener(
      'turbo:before-visit',
      this.preventTurboNavigation.bind(this),
    )
    window.addEventListener('beforeunload', this.preventFullPageNavigation.bind(this))
  }

  disconnect() {
    window.removeEventListener(
      'turbo:before-visit',
      this.preventTurboNavigation.bind(this),
    )
    window.removeEventListener(
      'beforeunload',
      this.preventFullPageNavigation.bind(this),
    )
  }

  trackChanges() {
    this.isDirty = true
  }

  preventTurboNavigation(event) {
    if (this.isDirty) {
      const message = 'Are you sure you want to navigate away from the page? You will lose all your changes.'

      if (window.confirm(message)) {
        this.isDirty = false
      } else {
        event.preventDefault()
      }
    }
  }

  preventFullPageNavigation(event) {
    if (this.isDirty) {
      event.preventDefault()

      // for legacy browsers support
      // see: https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
      event.returnValue = 'Are you sure you want to navigate away from the page? You will lose all your changes.'
    }
  }
}
