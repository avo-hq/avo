import { Controller } from '@hotwired/stimulus'

/**
 * Per-field wrapper controller for the bulk-update slide-out.
 *
 * Responsibilities:
 *   - On `connect`, snapshot the field input's initial value (this is the baseline
 *     for "unchanged" in a bulk update; fields render blank, so this is typically
 *     an empty string).
 *   - Listen for trusted user-input events (`input`, `change`) and compare the
 *     current value to the baseline. Toggle a `data-dirty` attribute on the
 *     wrapper to reflect the dirty state.
 *   - Dispatch a bubbling `bulk-update:field-changed` custom event carrying
 *     `{ key, isDirty, value }` so the parent form controller can track which
 *     keys to serialize.
 *
 * Programmatic value changes (autofill, Stimulus mutations not triggered by user
 * input) MUST NOT fire the dirty event. We gate on `event.isTrusted` for
 * exactly that reason.
 */
export default class extends Controller {
  static values = {
    key: String,
  }

  connect() {
    this.input = this.findInput()
    if (!this.input) return

    this.initialValue = this.readValue(this.input)
    this.isDirty = false
    this.element.removeAttribute('data-dirty')

    this.handleInput = this.handleInput.bind(this)
    this.input.addEventListener('input', this.handleInput)
    this.input.addEventListener('change', this.handleInput)
  }

  disconnect() {
    if (!this.input) return
    this.input.removeEventListener('input', this.handleInput)
    this.input.removeEventListener('change', this.handleInput)
  }

  /**
   * Locate the canonical "value" input within the wrapper.
   *
   * Most fields are a single input/select/textarea. For composite fields (e.g.
   * belongs_to with a visible search input + hidden ID input), the data-attr
   * `data-bulk-update-field-input` is used to pin the canonical input.
   */
  findInput() {
    const explicit = this.element.querySelector(
      '[data-bulk-update-field-input]',
    )
    if (explicit) return explicit

    return this.element.querySelector(
      'input:not([type="hidden"]):not([type="button"]):not([type="submit"]), select, textarea',
    )
  }

  /**
   * Read the input's current value in a type-aware way.
   *  - checkbox: boolean checked state stringified
   *  - select-multiple: sorted comma-joined selected values
   *  - everything else: `.value`
   */
  readValue(input) {
    if (input.type === 'checkbox') {
      return input.checked ? 'true' : 'false'
    }

    if (input.tagName === 'SELECT' && input.multiple) {
      return Array.from(input.selectedOptions)
        .map((opt) => opt.value)
        .sort()
        .join(',')
    }

    return input.value == null ? '' : String(input.value)
  }

  handleInput(event) {
    // Only trusted user-input events should mark a field dirty.
    // Programmatic dispatches (autofill, Stimulus mutations) are ignored.
    if (event && event.isTrusted === false) return

    const currentValue = this.readValue(this.input)
    const nextIsDirty = currentValue !== this.initialValue

    // Always toggle the data-attribute so the wrapper visibly reflects state.
    if (nextIsDirty) {
      this.element.setAttribute('data-dirty', '')
    } else {
      this.element.removeAttribute('data-dirty')
    }

    // Skip the dispatch if dirty state didn't actually change.
    if (nextIsDirty === this.isDirty) return
    this.isDirty = nextIsDirty

    this.dispatch('field-changed', {
      prefix: 'bulk-update',
      bubbles: true,
      detail: {
        key: this.keyValue,
        isDirty: nextIsDirty,
        value: currentValue,
      },
    })
  }
}
