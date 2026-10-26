/* eslint-disable max-len */
import DOMPurify from 'dompurify'
import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../../helpers/cast_boolean'
import Sortable from 'sortablejs'

export default class extends Controller {
  static targets = ['input', 'controller', 'rows', 'suggestions', 'suggestionsList']

  fieldValue = []

  options = {}

  // Keys mapped to the values suggested for them, e.g. { 'Content-Type': ['application/json'] }
  suggestions = {}

  // The input the suggestions panel is currently attached to, and the highlighted option in it
  suggestionsInput = null

  activeSuggestionIndex = -1

  get keyInputDisabled() {
    return !this.options.editable || this.options.disable_editing_keys
  }

  get valueInputDisabled() {
    return !this.options.editable || this.options.disable_editing_values
  }

  get prefersReducedMotion() {
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches
  }

  connect() {
    this.setOptions()
    this.setSuggestions()

    try {
      const objectValue = JSON.parse(this.inputTarget.value, (key, value) => {
        // convert primitives to string
        if (
          typeof value === "number" ||
          typeof value === "boolean"
        ) {
          return String(value);
        }
        return value; // objects stay objects
      });

      Object.keys(objectValue).forEach((key) => this.fieldValue.push([key, objectValue[key]]))
    } catch (error) {
      this.fieldValue = []
    }

    this.updateKeyValueComponent()
  }

  disconnect() {
    this.hideSuggestions()
  }

  addRow() {
    if (this.options.disable_adding_rows || !this.options.editable) return
    this.fieldValue.push(['', ''])
    this.updateKeyValueComponent()
    this.focusLastRow()
    this.animateLastRow()
  }

  deleteRow(event) {
    if (this.options.disable_deleting_rows || !this.options.editable) return
    const { index } = event.params
    const row = this.rowsTarget.querySelectorAll('.key-value__row')[index]

    // Update the data model right away so the form stays correct even if it is
    // submitted before the exit animation finishes.
    this.fieldValue.splice(index, 1)
    this.updateTextareaInput()

    if (!row || this.prefersReducedMotion) {
      this.updateKeyValueComponent()
      return
    }

    // Keep the (now stale) row on screen just long enough to animate it out,
    // then rebuild the list to re-sync indices.
    row.classList.add('key-value__row--leaving')
    row.addEventListener('animationend', () => this.updateKeyValueComponent(), { once: true })
  }

  moveKey(fromIndex, toIndex) {
    if (!this.options.editable) return

    this.fieldValue = this.moveElement(this.fieldValue, fromIndex, toIndex)

    this.updateTextareaInput()
    this.updateKeyValueComponent()
  }

  moveElement(array, fromIndex, toIndex) {
    const element = array[fromIndex]

    // remove 1 item at fromIndex
    array.splice(fromIndex, 1)

    // insert element at toIndex
    array.splice(toIndex, 0, element)

    return array
  }

  get lastRow() {
    return this.rowsTarget.querySelector('.key-value__row:last-child')
  }

  focusLastRow() {
    const input = this.lastRow?.querySelector('.key-value-input-key')
    if (!input) return

    input.focus()
    // Stimulus hasn't bound the new row's focus action yet, so open the suggestions here
    this.showSuggestions({ target: input })
  }

  animateLastRow() {
    const row = this.lastRow
    if (!row || this.prefersReducedMotion) return

    row.classList.add('key-value__row--entering')
    row.addEventListener(
      'animationend',
      () => {
        row.classList.remove('key-value__row--entering')
        // The row slid in, so line the suggestions panel up with its final spot
        this.positionSuggestions()
      },
      { once: true },
    )
  }

  valueFieldUpdated(event) {
    const { value } = event.target
    const { index } = event.target.dataset
    this.fieldValue[index][1] = value

    this.updateTextareaInput()
    this.showSuggestions(event)
  }

  keyFieldUpdated(event) {
    const { value } = event.target
    const { index } = event.target.dataset
    this.fieldValue[index][0] = value

    this.updateTextareaInput()
    this.showSuggestions(event)
  }

  get hasSuggestions() {
    return this.hasSuggestionsTarget && Object.keys(this.suggestions).length > 0
  }

  suggestionsEnabledFor(id) {
    return this.hasSuggestions && !this[`${id}InputDisabled`]
  }

  // Keys not used by another row, or the values suggested for the row's key, that contain what was typed
  suggestionsFor(input) {
    const { index } = input.dataset
    const query = input.value.trim().toLowerCase()
    let candidates

    if (input.classList.contains('key-value-input-key')) {
      const usedKeys = this.fieldValue.filter((_, rowIndex) => String(rowIndex) !== index).map(([key]) => key)
      candidates = Object.keys(this.suggestions).filter((key) => !usedKeys.includes(key))
    } else {
      candidates = this.suggestions[this.fieldValue[index]?.[0]] || []
    }

    return candidates.filter((candidate) => candidate.toLowerCase().includes(query) && candidate !== input.value)
  }

  showSuggestions(event) {
    const input = event.target
    if (!this.hasSuggestions || input.disabled || !input.hasAttribute('aria-controls')) return

    const candidates = this.suggestionsFor(input)
    if (candidates.length === 0) {
      this.hideSuggestions()

      return
    }

    this.suggestionsInput = input
    this.activeSuggestionIndex = -1
    this.suggestionsListTarget.setAttribute('aria-label', input.placeholder)
    this.suggestionsListTarget.innerHTML = candidates.map((candidate, index) => `<div
      class="dropdown-menu__item key-value__suggestion"
      role="option"
      id="${this.suggestionsListTarget.id}-${index}"
      aria-selected="false"
      data-value="${this.escapeAttribute(candidate)}"
      data-action="mousedown->key-value#pickSuggestion"
    >${this.escapeAttribute(candidate)}</div>`).join('')

    if (!this.suggestionsTarget.matches(':popover-open')) this.suggestionsTarget.showPopover()
    input.setAttribute('aria-expanded', 'true')
    this.positionSuggestions()
    this.#listenForScroll()
  }

  hideSuggestions() {
    if (!this.hasSuggestionsTarget) return

    if (this.suggestionsTarget.matches(':popover-open')) this.suggestionsTarget.hidePopover()
    this.suggestionsInput?.setAttribute('aria-expanded', 'false')
    this.suggestionsInput?.removeAttribute('aria-activedescendant')
    this.suggestionsInput = null
    this.activeSuggestionIndex = -1
    this.#stopListeningForScroll()
  }

  // The panel lives in the top layer, so it follows its input by hand while the page scrolls
  positionSuggestions = () => {
    if (!this.suggestionsInput) return

    const rect = this.suggestionsInput.getBoundingClientRect()
    const panel = this.suggestionsTarget
    const spaceBelow = window.innerHeight - rect.bottom
    const openUpwards = spaceBelow < panel.offsetHeight + 8 && rect.top > spaceBelow

    panel.style.width = `${rect.width}px`
    panel.style.left = `${rect.left}px`
    panel.style.top = openUpwards ? `${rect.top - panel.offsetHeight - 4}px` : `${rect.bottom + 4}px`
  }

  suggestionsKeydown(event) {
    if (!this.suggestionsInput || this.suggestionsInput !== event.target) {
      if (event.key === 'ArrowDown') this.showSuggestions(event)

      return
    }

    const items = this.suggestionsListTarget.querySelectorAll('[role="option"]')

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.highlightSuggestion((this.activeSuggestionIndex + 1) % items.length)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.highlightSuggestion((this.activeSuggestionIndex - 1 + items.length) % items.length)
        break
      case 'Enter':
        if (this.activeSuggestionIndex < 0) return

        // Don't submit the form while picking a suggestion
        event.preventDefault()
        this.selectSuggestion(items[this.activeSuggestionIndex].dataset.value)
        break
      case 'Escape':
        event.preventDefault()
        event.stopPropagation()
        this.hideSuggestions()
        break
      default:
    }
  }

  highlightSuggestion(index) {
    const items = this.suggestionsListTarget.querySelectorAll('[role="option"]')

    items.forEach((item, itemIndex) => {
      const active = itemIndex === index
      item.classList.toggle('dropdown-menu__item--active', active)
      item.setAttribute('aria-selected', String(active))
      if (active) {
        item.scrollIntoView({ block: 'nearest' })
        this.suggestionsInput.setAttribute('aria-activedescendant', item.id)
      }
    })

    this.activeSuggestionIndex = index
  }

  pickSuggestion(event) {
    // Keep the focus on the input so it doesn't blur and close the panel first
    event.preventDefault()
    this.selectSuggestion(event.currentTarget.dataset.value)
  }

  // Fill the input as if the user typed the suggestion, then move on to the value when a key was picked
  selectSuggestion(value) {
    const input = this.suggestionsInput
    if (!input) return

    input.value = value
    input.dispatchEvent(new Event('input', { bubbles: true }))
    this.hideSuggestions()

    if (input.classList.contains('key-value-input-key')) {
      const valueInput = this.rowsTarget.querySelector(`.key-value-input-value[data-index="${input.dataset.index}"]`)
      if (valueInput && !valueInput.disabled && valueInput.value === '') valueInput.focus()
    }
  }

  #listenForScroll() {
    window.addEventListener('scroll', this.positionSuggestions, true)
    window.addEventListener('resize', this.positionSuggestions)
  }

  #stopListeningForScroll() {
    window.removeEventListener('scroll', this.positionSuggestions, true)
    window.removeEventListener('resize', this.positionSuggestions)
  }

  updateTextareaInput() {
    if (!this.hasInputTarget) return
    let result = {}
    if (this.fieldValue && this.fieldValue.length > 0) {
      result = Object.assign(...this.fieldValue.map(([key, val]) => ({ [key]: val })))
    }
    this.inputTarget.innerText = JSON.stringify(result)
    this.inputTarget.dispatchEvent(new Event('input'))
  }

  updateKeyValueComponent() {
    // The rows are rebuilt, so the input the panel points at is about to go away
    this.hideSuggestions()
    let result = ''
    let index = 0
    this.fieldValue.forEach((row) => {
      const [key, value] = row
      result += this.interpolatedRow(DOMPurify.sanitize(key), DOMPurify.sanitize(value), index)
      index++
    })
    this.rowsTarget.innerHTML = result
    this.#initDragNDrop()
    window.initTippy()
  }

  #initDragNDrop() {
    const vm = this
    // eslint-disable-next-line no-new
    new Sortable(this.rowsTarget, {
      animation: 150,
      handle: '[data-control="dnd-handle"]',
      onUpdate(event) {
        vm.moveKey(event.oldIndex, event.newIndex)
      },
    })
  }

  interpolatedRow(key, value, index) {
    let result = '<div class="key-value__row" role="row">'

    result += `
      ${this.inputCell('key', index, key, value)}
      ${this.inputCell('value', index, key, value)}
    `

    if (this.options.editable) {
      result += `<div class="key-value__cell key-value__cell--actions">`
      result += this.dndIcon(index)
      result += this.deleteButton(index)
      result += '</div>'
    }

    result += '</div>'

    return result
  }

  inputCell(id = 'key', index, key, value) {
    const inputValue = id === 'key' ? key : value
    const suggestionsAttributes = this.suggestionsEnabledFor(id) ? `
    role="combobox"
    aria-autocomplete="list"
    aria-expanded="false"
    aria-controls="${this.suggestionsListTarget.id}"
    autocomplete="off"` : ''

    return `<div class="key-value__cell key-value__cell--${id}">
  <input
    class="${this.options.inputClasses} key-value__input key-value-input-${id}"
    data-action="input->key-value#${id}FieldUpdated${suggestionsAttributes ? ' focus->key-value#showSuggestions keydown->key-value#suggestionsKeydown blur->key-value#hideSuggestions' : ''}"${suggestionsAttributes}
    placeholder="${this.options[`${id}_label`]}"
    data-index="${index}"
    ${this[`${id}InputDisabled`] ? "disabled='disabled'" : ''}
    value="${this.escapeAttribute(inputValue)}"
  />
</div>`
  }

  escapeAttribute(str) {
    if (str === null || str === undefined) return ''
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
  }

  deleteButton(index) {
    return `<a
      href="javascript:void(0);"
      data-key-value-index-param="${index}"
      data-action="click->key-value#deleteRow"
      title="${this.options.delete_text}"
      data-tippy="tooltip"
      data-button="delete-row"
      ${this.options.disable_deleting_rows ? "disabled='disabled'" : ''}
      class="key-value__action-button ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''}"
      >
        <svg class="key-value__action-icon" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
    </a>`
  }

  dndIcon(index) {
    return `<a
      href="javascript:void(0);"
      data-key-value-index-param="${index}"
      data-control="dnd-handle"
      title="${this.options.reorder_text}"
      data-tippy="tooltip"
      tabindex="-1"
      class="key-value__action-button key-value__action-button--drag ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''}"
      >
        <svg class="key-value__action-icon key-value__action-icon--small" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" /></svg>
    </a>`
  }

  setSuggestions() {
    try {
      this.suggestions = JSON.parse(this.controllerTarget.dataset.suggestions || '{}')
    } catch {
      this.suggestions = {}
    }
  }

  setOptions() {
    let fieldOptions

    try {
      fieldOptions = JSON.parse(this.controllerTarget.dataset.options)
    } catch (error) {
      fieldOptions = {}
    }
    this.options = {
      ...fieldOptions,
      inputClasses: this.controllerTarget.dataset.inputClasses,
      editable: castBoolean(this.controllerTarget.dataset.editable),
    }
  }
}
