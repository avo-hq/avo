import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Asks for confirmation before the user leaves a form with changed values.
// A change is any difference between the form's current values and the ones it had
// before the user's first interaction, so undoing an edit clears the warning and
// JS driven fields are covered as long as they keep a form input in sync.
export default class extends Controller {
  static values = { message: String, changedOnLoad: Boolean }

  initialValues = null

  leaving = false

  connect() {
    // Capture phase so the values are read before any field handler changes them.
    this.element.addEventListener('pointerdown', this.captureInitialValues, true)
    this.element.addEventListener('keydown', this.captureInitialValues, true)
    this.element.addEventListener('turbo:submit-start', this.allowLeaving)
    this.element.addEventListener('turbo:submit-end', this.blockLeavingAfterFailedSubmit)
    // Turbo stops the submit event of the forms it handles before it gets to the window, so this one only sees native submissions.
    window.addEventListener('submit', this.allowLeavingOnNativeSubmit)
    document.addEventListener('turbo:before-visit', this.confirmVisit)
    window.addEventListener('beforeunload', this.warnBeforeUnload)
    // Turbo restores back and forward from popstate, which can't be cancelled. The navigate event fires first and can.
    window.navigation?.addEventListener('navigate', this.confirmHistoryTraversal)
  }

  disconnect() {
    this.element.removeEventListener('pointerdown', this.captureInitialValues, true)
    this.element.removeEventListener('keydown', this.captureInitialValues, true)
    this.element.removeEventListener('turbo:submit-start', this.allowLeaving)
    this.element.removeEventListener('turbo:submit-end', this.blockLeavingAfterFailedSubmit)
    window.removeEventListener('submit', this.allowLeavingOnNativeSubmit)
    document.removeEventListener('turbo:before-visit', this.confirmVisit)
    window.removeEventListener('beforeunload', this.warnBeforeUnload)
    window.navigation?.removeEventListener('navigate', this.confirmHistoryTraversal)
  }

  captureInitialValues = () => {
    this.initialValues ??= this.serializeForm()
  }

  allowLeaving = () => {
    this.leaving = true
  }

  allowLeavingOnNativeSubmit = (event) => {
    if (event.target === this.element && !event.defaultPrevented) this.leaving = true
  }

  blockLeavingAfterFailedSubmit = (event) => {
    if (!event.detail.success) this.leaving = false
  }

  confirmVisit = async (event) => {
    if (!this.hasUnsavedChanges) return

    event.preventDefault()
    if (await Turbo.config.forms.confirm(this.messageValue)) {
      this.discardChanges()
      Turbo.visit(event.detail.url)
    }
  }

  warnBeforeUnload = (event) => {
    if (!this.hasUnsavedChanges) return

    event.preventDefault()
    // Browsers before Chrome 119 only show the prompt when returnValue is set.
    event.returnValue = true
  }

  confirmHistoryTraversal = async (event) => {
    // Browsers make back and forward cancelable once per user interaction, so pressing back again always leaves.
    if (event.navigationType !== 'traverse' || !event.cancelable || !this.hasUnsavedChanges) return

    event.preventDefault()
    if (await Turbo.config.forms.confirm(this.messageValue)) {
      this.discardChanges()
      window.navigation.traverseTo(event.destination.key)
    }
  }

  discardChanges() {
    this.leaving = true
    // Keeps the discarded values out of Turbo's cache, so coming back loads the form from the server.
    Turbo.cache.exemptPageFromCache()
  }

  get hasUnsavedChanges() {
    if (this.leaving) return false
    if (this.changedOnLoadValue) return true

    return this.initialValues !== null && this.initialValues !== this.serializeForm()
  }

  serializeForm() {
    const { associationInputNames } = this
    // An empty file input yields a new File on every read, with lastModified set to that moment, so only name and size are compared.
    const formEntries = [...new FormData(this.element)]
      .filter(([name]) => !associationInputNames.has(name))
      .map(([name, value]) => [
        name,
        value instanceof File ? `${value.name}:${value.size}` : value,
      ])

    return JSON.stringify(formEntries)
  }

  // An association shown on the form loads in a frame and brings its own search and scope inputs, which are not values of the record.
  get associationInputNames() {
    // Only the frames inside of the form, which may sit in a frame itself, and only the ones loaded from another URL.
    const inputs = this.element.querySelectorAll(':scope turbo-frame[src] [name]')

    return new Set([...inputs].map((input) => input.getAttribute('name')))
  }
}
