/* eslint-disable max-len */
import * as DOMPurify from 'dompurify'
import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../../helpers/cast_boolean'

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

  moveKey(event) {
    if (!this.options.editable) return

    const { index, direction } = event.params
    const toIndex = direction === 'up' ? index - 1 : index + 1
    this.fieldValue = this.moveElement(this.fieldValue, index, toIndex)

    this.updateTextareaInput()
    this.updateKeyValueComponent()
  }

  moveElement(arr, fromIndex, toIndex) {
    return arr.map((item, index) => {
      if (index === toIndex) return arr[fromIndex]
      if (index === fromIndex) return arr[toIndex]

      return item
    })
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
    window.initTippy()
  }

  interpolatedRow(key, value, index) {
    let result = '<div class="flex key-value-row">'
    if (this.options.editable) {
      result += `<a
      href="javascript:void(0);"
      data-key-value-index-param="${index}"
      data-key-value-direction-param="up"
      data-action="click->key-value#moveKey"
      title="up"
      data-tippy="tooltip"
      data-button="up-row"
      tabindex="-1"
      class="flex items-center justify-center p-2 px-3 border-none ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''} ${index === 0 ? 'invisible' : ''}"
      ><svg class="pointer-events-none text-gray-500 h-5 hover:text-gray-500" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M5 10l7-7m0 0l7 7m-7-7v18" /></svg></a>
      <a
      href="javascript:void(0);"
      data-key-value-index-param="${index}"
      data-key-value-direction-param="down"
      data-action="click->key-value#moveKey"
      title="down"
      data-tippy="tooltip"
      data-button="down-row"
      tabindex="-1"
      class="flex items-center justify-center p-2 px-3 border-none ${this.options.disable_deleting_rows ? 'cursor-not-allowed' : ''} ${index === this.fieldValue.length - 1 ? 'invisible' : ''}"
      ><svg class="pointer-events-none text-gray-500 h-5 hover:text-gray-500" fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M19 14l-7 7m0 0l-7-7m7 7V3" /></svg></a>`
    }

    result += `
      ${this.inputField('key', index, key, value)}
      ${this.inputField('value', index, key, value)}
    `

    if (this.options.editable) {
      result += `<a
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
