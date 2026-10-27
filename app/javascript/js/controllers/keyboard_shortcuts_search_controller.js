import { Controller } from '@hotwired/stimulus'

// Filters the rows inside the keyboard shortcuts modal as the user types.
// Hides non-matching rows and any section left empty, and reveals an empty
// state when nothing matches. Focus is handed to the input whenever the modal
// (a popover) opens, and the query is reset on close so each visit starts fresh.
export default class extends Controller {
  static targets = ['input', 'section', 'row', 'empty']

  connect() {
    this.modal = this.element.closest('.modal')
    if (this.modal) {
      this.handleToggle = this.onModalToggle.bind(this)
      this.modal.addEventListener('toggle', this.handleToggle)
    }
  }

  disconnect() {
    if (this.modal) this.modal.removeEventListener('toggle', this.handleToggle)
  }

  onModalToggle(event) {
    if (event.newState === 'open') {
      this.reset()
      // Defer focus until the popover is painted and focusable.
      requestAnimationFrame(() => this.inputTarget.focus())
    } else {
      this.reset()
    }
  }

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()

    let anyVisible = false
    const ranges = []

    this.sectionTargets.forEach((section) => {
      let sectionHasMatch = false

      this.rowsFor(section).forEach((row) => {
        const match = query === '' || this.searchText(row).includes(query)
        row.hidden = !match
        if (match) sectionHasMatch = true
        if (match && query) ranges.push(...this.matchRanges(row, query))
      })

      section.hidden = !sectionHasMatch
      if (sectionHasMatch) anyVisible = true
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = anyVisible || query === ''

    // The CSS Custom Highlight API paints the matches without touching the row markup. Browsers without it
    // still filter, just unhighlighted.
    if (window.CSS?.highlights) CSS.highlights.set('hotkey-search', new Highlight(...ranges))
  }

  // Only the action label is highlighted: key badges are split across <kbd> tags and read as glyphs.
  matchRanges(row, query) {
    const text = row.querySelector('.hotkey__action')?.firstChild
    if (text?.nodeType !== Node.TEXT_NODE) return []

    const ranges = []
    const haystack = text.textContent.toLowerCase()
    for (let index = haystack.indexOf(query); index !== -1; index = haystack.indexOf(query, index + query.length)) {
      const range = new Range()
      range.setStart(text, index)
      range.setEnd(text, index + query.length)
      ranges.push(range)
    }

    return ranges
  }

  // Escape clears a non-empty query before the modal handles it as a close.
  clearOnEscape(event) {
    if (this.inputTarget.value === '') return

    event.stopPropagation()
    this.reset()
    this.inputTarget.focus()
  }

  reset() {
    this.inputTarget.value = ''
    this.filter()
  }

  rowsFor(section) {
    return this.rowTargets.filter((row) => section.contains(row))
  }

  searchText(row) {
    if (!row.dataset.searchText) {
      row.dataset.searchText = row.textContent.replace(/\s+/g, ' ').trim().toLowerCase()
    }

    return row.dataset.searchText
  }
}
