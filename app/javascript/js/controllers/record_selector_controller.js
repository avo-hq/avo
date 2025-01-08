/* eslint-disable radix */
import { Controller } from '@hotwired/stimulus'
import difference from 'lodash/difference'
import range from 'lodash/range'

// Hopefully we'll never need to touch this code again
export default class extends Controller {
  lastCheckedIndex = null

  autoClicking = false

  get itemSelectorCells() {
    return document.querySelectorAll('.item-selector-cell')
  }

  get hasLastCheckedIndex() {
    return this.lastCheckedIndex !== null
  }

  connect() {
    this.#addEventListeners()
  }

  disconnect() {
    this.#removeEventListeners()
  }

  // Toggle multiple items
  toggleMultiple(event) {
    // this check is to prevent the method from running twice when the script clicks the checkboxes
    if (this.autoClicking) {
      return
    }

    // If there's no last checked index and the shift key isn't pressed, set the starting index
    if (!this.hasLastCheckedIndex) {
      this.#setStartingIndex(event)

      return
    }

    // Ignore action if shift key is not pressed
    if (!event.shiftKey) {
      this.#resetLastCheckedIndex()

      return
    }

    const currentIndex = parseInt(event.target.dataset.index)
    const theRange = difference(range(this.lastCheckedIndex, currentIndex), [this.lastCheckedIndex, currentIndex])

    // Set the autoClicking flag to true to prevent the method from running twice
    this.autoClicking = true

    // Get the state of the target checkbox
    const state = event.target.checked

    // Loop through the range of rows and toggle the checkboxes
    theRange.forEach((index) => {
      const checkbox = document.querySelector(`input[type="checkbox"][data-index="${index}"]`)

      // Toggle the checkbox if it's not in the same state as the target checkbox
      if (checkbox.checked !== state) {
        checkbox.click()
      }
    })

    this.#setEndingIndex(event)

    // Reset the autoClicking flag
    this.autoClicking = false

    // Reset the last checked index
    this.#resetLastCheckedIndex()

    this.#resetEventListeners()
  }

  #resetEventListeners() {
    this.#removeEventListeners()
    this.#addEventListeners()
  }

  #addEventListeners() {
    // Attach event listeners to item selector cells
    Array.from(this.itemSelectorCells).forEach((itemSelectorCell) => {
      itemSelectorCell.addEventListener('mouseenter', this.#selectorMouseenterHandler.bind(this))
      itemSelectorCell.addEventListener('mouseleave', this.#selectorMouseleaveHandler.bind(this))
    })

    // Attach event listeners to keyboard events
    document.addEventListener('keydown', this.#keydownHandler)
    document.addEventListener('keyup', this.#keyupHandler)
  }

  #removeEventListeners() {
    // Remove event listeners
    Array.from(this.itemSelectorCells).forEach((itemSelectorCell) => {
      itemSelectorCell.removeEventListener('mouseenter', this.#selectorMouseenterHandler.bind(this))
      itemSelectorCell.removeEventListener('mouseleave', this.#selectorMouseleaveHandler.bind(this))
    })
    document.removeEventListener('keydown', this.#keydownHandler.bind(this))
    document.removeEventListener('keyup', this.#keyupHandler.bind(this))
  }

  #selectorMouseenterHandler(event) {
    // Add the highlighted-row class to the row that the mouse is over
    event.target.closest('tr').classList.add('highlighted-row')
    if (this.lastCheckedIndex) {
      // Highlight the range of rows between the last checked index and the current index
      this.#highlightRange(this.lastCheckedIndex, parseInt(event.target.closest('tr').dataset.index))
    }
  }

  #selectorMouseleaveHandler(event) {
    // Remove the highlighted-row class from the row that the mouse is over
    event.target.closest('tr').classList.remove('highlighted-row')
    // Remove the highlighted-row class from all rows
    document.querySelectorAll('tr[data-index]').forEach((tr) => {
      tr.classList.remove('highlighted-row')
    })
  }

  // Highlight the range of rows between the start index and the end index
  #highlightRange(startIndex, endIndex) {
    const theRange = difference(range(startIndex, endIndex))
    theRange.forEach((index) => {
      const tr = document.querySelector(`tr[data-index="${index}"]`)
      tr.classList.add('highlighted-row')
    })
  }

  // Add the shift-pressed class to the body when the shift key is pressed
  #keydownHandler(event) {
    if (event.shiftKey) {
      document.body.classList.add('shift-pressed')
    }
  }

  // Remove the shift-pressed class from the body when the shift key is released
  #keyupHandler(event) {
    if (!event.shiftKey) {
      document.body.classList.remove('shift-pressed')
    }
  }

  #resetLastCheckedIndex() {
    this.lastCheckedIndex = null
  }

  // Set the starting index
  #setStartingIndex(event) {
    this.lastCheckedIndex = parseInt(event.target.dataset.index)
    event.target.closest('tr').classList.add('highlighted-row')
  }

  // Set the ending index
  #setEndingIndex(event) {
    this.lastCheckedIndex = parseInt(event.target.dataset.index)
    event.target.closest('tr').classList.add('highlighted-row')
  }
}
