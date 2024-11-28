/* eslint-disable max-len */
import * as DOMPurify from 'dompurify'
import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../../helpers/cast_boolean'
import Sortable from 'sortablejs'

export default class extends Controller {
  static targets = ['input', 'controller', 'rows']

  fieldValue = []

  options = {}

  get keyInputDisabled() {
    return !this.options.editable || this.options.disable_editing_keys
  }

  get valueInputDisabled() {
    return !this.options.editable || this.options.disable_editing_values
  }

  connect() {
    this.setOptions()

    try {
      const objectValue = JSON.parse(this.inputTarget.value)
      Object.keys(objectValue).forEach((key) => this.fieldValue.push([key, objectValue[key]]))
    } catch (error) {
      this.fieldValue = []
    }

    this.updateKeyValueComponent()
  }

  addRow() {
    if (this.options.disable_adding_rows || !this.options.editable) return
    this.fieldValue.push(['', ''])
    this.updateKeyValueComponent()
    this.focusLastRow()
  }

  deleteRow(event) {
    if (this.options.disable_deleting_rows || !this.options.editable) return
    const { index } = event.params
    this.fieldValue.splice(index, 1)
    this.updateTextareaInput()
    this.updateKeyValueComponent()
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

  focusLastRow() {
    return this.rowsTarget.querySelector('.flex.key-value-row:last-child .key-value-input-key').focus()
  }

  valueFieldUpdated(event) {
    const { value } = event.target
    const { index } = event.target.dataset
    this.fieldValue[index][1] = value

    this.updateTextareaInput()
  }

  keyFieldUpdated(event) {
    const { value } = event.target
    const { index } = event.target.dataset
    this.fieldValue[index][0] = value

    this.updateTextareaInput()
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
    let result = '<div class="flex key-value-row">'

    result += `
      ${this.inputField('key', index, key, value)}
      ${this.inputField('value', index, key, value)}
    `

    if (this.options.editable) {
      result += this.dndIcon(index)
      result += this.deleteButton(index)
    }

    result += '</div>'

    return result
  }

  inputField(id = 'key', index, key, value) {
    const inputValue = id === 'key' ? key : value

    return `<input
  class="${this.options.inputClasses} focus:bg-gray-100 !rounded-none border-gray-600 border-r border-l-0 border-b-0 border-t-0 focus:border-gray-300 w-1/2 focus:outline-none outline-none key-value-input-${id}"
  data-action="input->key-value#${id}FieldUpdated"
  placeholder="${this.options[`${id}_label`]}"
  data-index="${index}"
  ${this[`${id}InputDisabled`] ? "disabled='disabled'" : ''}
  value="${typeof inputValue === 'undefined' || inputValue === null ? '' : inputValue}"
/>`
  }

  deleteButton(index) {
    return `<a
              href="javascript:void(0);"
              data-key-value-index-param="${index}"
              data-action="click->key-value#deleteRow"
              title="${this.options.delete_text}"
              data-tippy="tooltip"
              data-button="delete-row"
              tabindex="-1"
              ${this.options.disable_deleting_rows ? "disabled='disabled'" : ''}
              class="flex items-center justify-center p-2 px-3 border-none ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''}"
            ><svg class="pointer-events-none text-gray-500 h-5 hover:text-gray-500" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg></a>`
  }

  dndIcon(index) {
    return `<div class="flex flex-col">
      <a
        href="javascript:void(0);"
        data-key-value-index-param="${index}"
        data-control="dnd-handle"
        title="${this.options.reorder_text}"
        data-tippy="tooltip"
        tabindex="-1"
        class="flex items-center justify-center py-0 px-2 border-none h-full ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''}"
        >
          <svg class="pointer-events-none text-gray-500 h-4 hover:text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" /></svg>
      </a>
    </div>`
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
