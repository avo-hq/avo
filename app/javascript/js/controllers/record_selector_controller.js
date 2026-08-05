/* eslint-disable radix */
import { Controller } from '@hotwired/stimulus'
import difference from 'lodash/difference'
import range from 'lodash/range'

// Hopefully we'll never need to touch this code again
export default class extends Controller {
  lastCheckedIndex = null

  autoClicking = false

  // Every lookup in here is scoped to this controller's element. A page can hold several tables (a
  // show page renders one per has_many association) and each numbers its rows from zero, so a
  // document-wide lookup by index always lands in the first table.
  get itemSelectorCells() {
    return this.element.querySelectorAll('.item-selector-cell')
  }

  #rowAt(index) {
    return this.element.querySelector(`tr[data-index="${index}"]`)
  }

  #checkboxAt(index) {
    return this.element.querySelector(`input[type="checkbox"][data-index="${index}"]`)
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

    // Ranges are addressed by row. Index view types outside a table (avo-notifications renders one)
    // give this component an index but no row to walk up to, so there's nothing to span.
    if (!event.target.closest('tr')) {
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
      const checkbox = this.#checkboxAt(index)

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
    // Create bound handler references so the same functions are used for add and remove
    this.boundMouseenterHandler = this.#selectorMouseenterHandler.bind(this)
    this.boundMouseleaveHandler = this.#selectorMouseleaveHandler.bind(this)

    // Attach event listeners to item selector cells
    Array.from(this.itemSelectorCells).forEach((itemSelectorCell) => {
      itemSelectorCell.addEventListener('mouseenter', this.boundMouseenterHandler)
      itemSelectorCell.addEventListener('mouseleave', this.boundMouseleaveHandler)
    })

    // Attach event listeners to keyboard events
    document.addEventListener('keydown', this.#keydownHandler)
    document.addEventListener('keyup', this.#keyupHandler)
  }

  #removeEventListeners() {
    // Remove event listeners using the same bound references from #addEventListeners
    Array.from(this.itemSelectorCells).forEach((itemSelectorCell) => {
      itemSelectorCell.removeEventListener('mouseenter', this.boundMouseenterHandler)
      itemSelectorCell.removeEventListener('mouseleave', this.boundMouseleaveHandler)
    })
    document.removeEventListener('keydown', this.#keydownHandler)
    document.removeEventListener('keyup', this.#keyupHandler)
  }

  #selectorMouseenterHandler(event) {
    // Add the highlighted-row class to the row that the mouse is over
    event.target.closest('tr').classList.add('highlighted-row')
    // Check against null, not truthiness — index 0 is a valid anchor
    if (this.hasLastCheckedIndex) {
      // Highlight the range of rows between the last checked index and the current index
      this.#highlightRange(this.lastCheckedIndex, parseInt(event.target.closest('tr').dataset.index))
    }
  }

  #selectorMouseleaveHandler(event) {
    // Remove the highlighted-row class from the row that the mouse is over
    event.target.closest('tr').classList.remove('highlighted-row')
    // Remove the highlighted-row class from all rows
    this.element.querySelectorAll('tr[data-index]').forEach((tr) => {
      tr.classList.remove('highlighted-row')
    })
  }

  // Highlight the range of rows between the start index and the end index
  #highlightRange(startIndex, endIndex) {
    // `range` excludes the end index, but the hovered row is highlighted by the caller
    range(startIndex, endIndex).forEach((index) => {
      this.#rowAt(index).classList.add('highlighted-row')
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
