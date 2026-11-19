import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

const TYPING_SELECTOR = 'input:not([type="checkbox"]):not([type="radio"]), textarea, select, [contenteditable]'

// Reloads an index's records every few seconds, for resources that set `index_refresh_every`.
// It asks for the list the way the search does, so the server answers with a Turbo Stream that replaces
// this element. The new element schedules the next reload, and a reload still on its way when the element
// goes (a search or a navigation replaced it) is dropped, so it can't put back an older list.
export default class extends Controller {
  static values = { url: String, interval: Number }

  #timer = null

  #abortController = null

  connect() {
    this.#schedule()
  }

  disconnect() {
    clearTimeout(this.#timer)
    this.#abortController?.abort()
  }

  // Private

  async #refresh() {
    if (this.#shouldWait) {
      this.#schedule()

      return
    }

    this.#abortController = new AbortController()

    try {
      await get(this.urlValue, {
        responseKind: 'turbo-stream',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'X-Search-Request': 'resource-search-controller',
        },
        signal: this.#abortController.signal,
      })
    } catch {
      // A failed or dropped reload leaves the list as it is.
    }

    // When the reload worked, this element was replaced and its replacement scheduled the next one.
    if (this.element.isConnected) this.#schedule()
  }

  #schedule() {
    clearTimeout(this.#timer)
    this.#timer = setTimeout(() => this.#refresh(), this.intervalValue)
  }

  // The reload waits for the next turn while nobody would see it (the browser tab is in the background, or the
  // list sits in an inactive tab of the page), and while replacing the list would throw away what the user is
  // doing with it: rows are selected, a row menu is open, the keyboard is moving through the list, or the user
  // is typing (a search, a filter, an action's fields).
  get #shouldWait() {
    return document.hidden
      || this.element.getClientRects().length === 0
      || this.#hasSelectedRecords
      || this.element.querySelector('dialog[open], :focus-visible') !== null
      || document.activeElement?.matches(TYPING_SELECTOR) === true
  }

  get #hasSelectedRecords() {
    return [...this.element.querySelectorAll('[data-selected-resources]')].some((element) => {
      try {
        return JSON.parse(element.dataset.selectedResources).length > 0
      } catch {
        return false
      }
    })
  }
}
