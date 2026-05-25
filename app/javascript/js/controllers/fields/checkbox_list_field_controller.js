import { Controller } from '@hotwired/stimulus'
import { toggleHidden } from '../../helpers/toggle_hidden'

const CHECKBOX_SELECTOR = 'input[type="checkbox"]'

export default class extends Controller {
  static targets = ['input', 'row', 'empty', 'hiddenSelections']

  static values = {
    hiddenSelectionsOne: String,
    hiddenSelectionsOther: String,
  }

  filter(event) {
    if (event && event.target !== this.inputTarget) return

    const query = this.normalize(this.inputTarget.value)
    let visibleCount = 0
    let hiddenCheckedCount = 0

    this.rowTargets.forEach((row) => {
      const isVisible = query.length === 0 || this.normalize(row.dataset.checkboxListFieldSearchText).includes(query)
      const checkbox = row.querySelector(CHECKBOX_SELECTOR)

      this.setHidden(row, !isVisible)

      if (checkbox) {
        checkbox.disabled = !isVisible || checkbox.defaultDisabled

        if (!isVisible && checkbox.checked) hiddenCheckedCount += 1
      }

      if (isVisible) visibleCount += 1
    })

    if (this.hasEmptyTarget) {
      this.setHidden(this.emptyTarget, visibleCount > 0)
    }

    this.updateHiddenSelections(hiddenCheckedCount)
  }

  handleKeydown(event) {
    if (event.key !== 'ArrowDown' && event.key !== 'ArrowUp') return

    if (event.target === this.inputTarget) {
      this.moveFromInput(event)
    } else if (event.target.matches(CHECKBOX_SELECTOR)) {
      this.moveBetweenRows(event)
    }
  }

  moveFromInput(event) {
    const rows = this.visibleRows
    if (rows.length === 0) return

    event.preventDefault()
    this.focusRow(event.key === 'ArrowDown' ? rows[0] : rows[rows.length - 1])
  }

  moveBetweenRows(event) {
    const rows = this.visibleRows
    const currentRow = event.target.closest('[data-checkbox-list-field-target~="row"]')
    const currentIndex = rows.indexOf(currentRow)

    if (currentIndex === -1) return

    event.preventDefault()

    const delta = event.key === 'ArrowDown' ? 1 : -1
    let nextIndex = currentIndex + delta
    if (nextIndex < 0) nextIndex = rows.length - 1
    if (nextIndex >= rows.length) nextIndex = 0

    this.focusRow(rows[nextIndex])
  }

  get visibleRows() {
    return this.rowTargets.filter((row) => !row.hasAttribute('hidden'))
  }

  focusRow(row) {
    row.querySelector(CHECKBOX_SELECTOR)?.focus()
    row.scrollIntoView({ block: 'nearest' })
  }

  setHidden(element, hidden) {
    if (element.hasAttribute('hidden') !== hidden) {
      toggleHidden(element)
    }
  }

  updateHiddenSelections(count) {
    if (!this.hasHiddenSelectionsTarget) return

    if (count === 0) {
      this.setHidden(this.hiddenSelectionsTarget, true)
      this.hiddenSelectionsTarget.textContent = ''
      return
    }

    this.hiddenSelectionsTarget.textContent = this.hiddenSelectionsLabel(count)
    this.setHidden(this.hiddenSelectionsTarget, false)
  }

  hiddenSelectionsLabel(count) {
    if (count === 1 && this.hasHiddenSelectionsOneValue) {
      return this.hiddenSelectionsOneValue
    }

    if (this.hasHiddenSelectionsOtherValue) {
      return this.hiddenSelectionsOtherValue.replace('%{count}', count)
    }

    return `${count} selected options hidden by search`
  }

  normalize(value) {
    return (value || '').toString().trim().toLowerCase()
  }
}
