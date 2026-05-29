import { Controller } from '@hotwired/stimulus'
import { toggleHidden } from '../helpers/toggle_hidden'

/**
 * Controller mounted on the bulk-update slide-out form.
 *
 * Owns the dirty-key set (built from bubbled `bulk-update:field-changed`
 * events), submit-in-flight gating, Cmd/Ctrl+Enter submission, and Esc /
 * backdrop / X discard-dialog gating.
 *
 * On `connect`, captures the index page's visible-row IDs from
 * `document.body.dataset.currentPageIds` and writes them into the hidden
 * `current_page_ids` form input so the controller's handle path can cap
 * per-row Turbo Stream replies (Unit 5b consumes this).
 *
 * Conventions:
 *   - Listens to `bulk-update:field-changed` events (bubbles up from
 *     `bulk_update_field_controller`).
 *   - Stores dirty keys in a `Set<string>`.
 *   - Submit-in-flight uses a `data-submit-in-flight` attribute on the form
 *     and disables the Submit button + all field inputs. Inputs whose key is
 *     NOT in `dirtyKeys` are disabled so they don't serialize.
 *   - The disabled-button state blocks both repeat-click and Cmd/Ctrl+Enter
 *     double-press from firing a second submit.
 *   - On Turbo response, success closes the slide-out via the server-rendered
 *     `turbo_stream.avo_close_slide_over`; partial-failure re-enables inputs
 *     so the user can retry; total-failure re-enables inputs and shows the
 *     error banner (server-rendered).
 *   - Esc / X / backdrop click toggles the in-component discard dialog via
 *     the `discardDialog` Stimulus target when `dirtyKeys.size > 0`.
 */
export default class extends Controller {
  static targets = ['submitButton', 'discardDialog', 'currentPageIds']

  connect() {
    this.dirtyKeys = new Set()
    this.inFlight = false

    this.handleFieldChanged = this.handleFieldChanged.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleTurboSubmitEnd = this.handleTurboSubmitEnd.bind(this)

    this.element.addEventListener(
      'bulk-update:field-changed',
      this.handleFieldChanged,
    )
    this.element.addEventListener('submit', this.handleSubmit)
    this.element.addEventListener('keydown', this.handleKeydown)
    this.element.addEventListener(
      'turbo:submit-end',
      this.handleTurboSubmitEnd,
    )

    this.captureCurrentPageIds()
  }

  disconnect() {
    this.element.removeEventListener(
      'bulk-update:field-changed',
      this.handleFieldChanged,
    )
    this.element.removeEventListener('submit', this.handleSubmit)
    this.element.removeEventListener('keydown', this.handleKeydown)
    this.element.removeEventListener(
      'turbo:submit-end',
      this.handleTurboSubmitEnd,
    )
  }

  // -- dirty-key management ---------------------------------------------------

  handleFieldChanged(event) {
    const { key, isDirty } = event.detail || {}
    if (!key) return

    if (isDirty) {
      this.dirtyKeys.add(key)
    } else {
      this.dirtyKeys.delete(key)
    }
  }

  // -- submit gating ----------------------------------------------------------

  handleSubmit(event) {
    if (this.inFlight) {
      // Second submit during in-flight: block.
      event.preventDefault()
      event.stopImmediatePropagation()
      return
    }

    this.enterInFlight()
  }

  /**
   * Cmd/Ctrl+Enter inside a text input submits the form.
   * Native browsers only submit on Enter for some input types; this
   * normalizes the convention for the slide-out.
   *
   * The Esc check defers to the discard-dialog gating below.
   */
  handleKeydown(event) {
    if (event.key === 'Enter' && (event.metaKey || event.ctrlKey)) {
      event.preventDefault()
      if (!this.inFlight) {
        this.element.requestSubmit()
      }
      return
    }

    if (event.key === 'Escape') {
      this.requestClose(event)
    }
  }

  /**
   * Called by Esc, the X button, or a backdrop click. If the form has dirty
   * keys, opens the in-component discard dialog instead of closing.
   *
   * The slide-out controller (Unit 2) is responsible for actually closing
   * when no dirty keys are present; this method only intercepts and gates.
   *
   * Returns true when the caller's close should be cancelled (because we
   * opened the discard dialog instead).
   */
  requestClose(event) {
    if (this.inFlight) {
      // Block close during submit-in-flight.
      if (event) {
        event.preventDefault()
        event.stopPropagation()
      }
      return true
    }

    if (this.dirtyKeys.size === 0) return false

    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    this.openDiscardDialog()
    return true
  }

  openDiscardDialog() {
    if (!this.hasDiscardDialogTarget) return
    if (this.discardDialogTarget.hasAttribute('hidden')) {
      toggleHidden(this.discardDialogTarget)
    }
  }

  closeDiscardDialog() {
    if (!this.hasDiscardDialogTarget) return
    if (!this.discardDialogTarget.hasAttribute('hidden')) {
      toggleHidden(this.discardDialogTarget)
    }
  }

  // -- submit-in-flight state -------------------------------------------------

  enterInFlight() {
    this.inFlight = true
    this.element.dataset.submitInFlight = 'true'

    // Disable inputs whose key is NOT in dirtyKeys so they don't serialize.
    this.fieldInputs().forEach((input) => {
      const wrapper = input.closest('[data-controller~="bulk-update-field"]')
      const key = wrapper?.dataset?.bulkUpdateFieldKeyValue
      if (key && !this.dirtyKeys.has(key)) {
        input.dataset.bulkUpdateDisabledByForm = 'true'
        input.disabled = true
      }
    })

    // Disable Submit button + swap copy.
    if (this.hasSubmitButtonTarget) {
      const button = this.submitButtonTarget
      if (!button.dataset.originalContent) {
        button.dataset.originalContent = button.innerHTML
      }
      const updating = button.dataset.updatingLabel
      if (updating) {
        button.innerHTML = updating
      }
      button.disabled = true
    }

    // Also disable dirty-keyed inputs so user can't edit during in-flight,
    // but DO leave them enabled in the form payload (they were already
    // enabled when the form serialized).
    this.fieldInputs().forEach((input) => {
      if (input.dataset.bulkUpdateDisabledByForm === 'true') return
      input.dataset.bulkUpdateDirtyDisabledByForm = 'true'
      input.disabled = true
    })
  }

  exitInFlight() {
    this.inFlight = false
    delete this.element.dataset.submitInFlight

    this.fieldInputs().forEach((input) => {
      if (
        input.dataset.bulkUpdateDisabledByForm === 'true' ||
        input.dataset.bulkUpdateDirtyDisabledByForm === 'true'
      ) {
        input.disabled = false
        delete input.dataset.bulkUpdateDisabledByForm
        delete input.dataset.bulkUpdateDirtyDisabledByForm
      }
    })

    if (this.hasSubmitButtonTarget) {
      const button = this.submitButtonTarget
      if (button.dataset.originalContent) {
        button.innerHTML = button.dataset.originalContent
      }
      button.disabled = false
    }
  }

  /**
   * Re-enable everything on partial-failure / total-failure so the user can
   * retry. The Turbo Stream response from the server is in charge of replacing
   * any visible failure UI; we only own the in-flight lock.
   *
   * On full-success the server closes the slide-out via
   * `turbo_stream.avo_close_slide_over` and this controller is disconnected,
   * so we don't have to handle the success path here explicitly. We still
   * call `exitInFlight()` defensively so partial-failure markup that lands
   * via `turbo_stream.replace` (and therefore does NOT disconnect this
   * controller) re-enables cleanly.
   */
  handleTurboSubmitEnd(event) {
    const success = event?.detail?.success
    if (success === false) {
      this.exitInFlight()
    } else {
      // Success or unknown: defensive re-enable in case the server didn't
      // close the slide-out (e.g., a non-close partial-success render).
      this.exitInFlight()
    }
  }

  // -- helpers ----------------------------------------------------------------

  /**
   * All inputs/selects/textareas inside `bulk-update-field` wrappers.
   */
  fieldInputs() {
    return this.element.querySelectorAll(
      '[data-controller~="bulk-update-field"] input, ' +
        '[data-controller~="bulk-update-field"] select, ' +
        '[data-controller~="bulk-update-field"] textarea',
    )
  }

  captureCurrentPageIds() {
    const ids = document.body.dataset.currentPageIds
    if (!ids) return

    if (this.hasCurrentPageIdsTarget) {
      this.currentPageIdsTarget.value = ids
      return
    }

    // Fallback: create a hidden input named `current_page_ids` so the
    // server can read it without the form template having to declare it.
    let hidden = this.element.querySelector(
      'input[type="hidden"][name="current_page_ids"]',
    )
    if (!hidden) {
      hidden = document.createElement('input')
      hidden.type = 'hidden'
      hidden.name = 'current_page_ids'
      this.element.appendChild(hidden)
    }
    hidden.value = ids
  }
}
