import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['form']

  connect() {
    this.isDirty = false
    this.isFormSubmitting = false
    this.currentLocationUrl = window.location.href

    this.initialFormState = this.getFormState()
    this.currentFormState = this.getFormState()

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

    this.formTarget.addEventListener('turbo:submit-start', this.handleFormSubmitStart.bind(this))
    this.formTarget.addEventListener('turbo:submit-end', this.handleFormSubmitEnd.bind(this))
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

  getFormState() {
    const formState = {}
    const formFieldsArray = [...this.formTarget.querySelectorAll('input, textarea, select')]
    const formFieldsWithIdentifier = formFieldsArray.filter((item) => Boolean(item.id))

    formFieldsWithIdentifier.forEach((item) => {
      let { value } = item

      if (item.type === 'checkbox') {
        value = item.checked
      }

      formState[item.id] = value
    })

    return formState
  }

  trackChanges(event) {
    const { target: { id, type: fieldType, checked } } = event

    let { target: { value } } = event

    if (fieldType === 'checkbox') {
      value = checked
    }

    this.currentFormState[id] = value
  }

  evaluateFormState() {
    const isFormDirty = Object.keys(this.initialFormState).some((key) => this.initialFormState[key] !== this.currentFormState[key])
    // for key value fields which are not present in initial state for new form
    const isNewFieldAdded = Object.keys(this.currentFormState).length > Object.keys(this.initialFormState).length

    this.isDirty = isFormDirty || isNewFieldAdded
  }

  handleFormSubmitStart() {
    this.isFormSubmitting = true
  }

  handleFormSubmitEnd(event) {
    if (event.detail.success) {
      this.resetState()
    }
  }

  resetState() {
    this.isDirty = false
    this.isFormSubmitting = false
    this.initialFormState = {}
    this.currentFormState = {}
  }

  preventTurboNavigation(event) {
    // don't intercept if URL doesn't change e.g. modals OR when form is submitting
    if (event.detail.url === this.currentLocationUrl || this.isFormSubmitting) {
      return
    }

    this.evaluateFormState()

    if (this.isDirty) {
      const message = 'Are you sure you want to navigate away from the page? You will lose all your changes.'

      if (window.confirm(message)) {
        this.resetState()
      } else {
        event.preventDefault()
      }
    }
  }

  preventFullPageNavigation(event) {
    this.evaluateFormState()

    if (this.isDirty) {
      event.preventDefault()

      // for legacy browsers support
      // see: https://developer.mozilla.org/en-US/docs/Web/API/Window/beforeunload_event
      event.returnValue = 'Are you sure you want to navigate away from the page? You will lose all your changes.'
    }
  }
}
