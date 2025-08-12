import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['input', 'overlay']

  static values = {
    debounce: { type: Number, default: 300 },
    url: String,
  }

  connect() {
    this.#clearSpinnerTimer()
    this.#removeSpinner()
  }

  disconnect() {
    this.#clearSpinnerTimer()
    this.#removeSpinner()
  }

  search() {
    this.debouncedSearch()
  }

  debouncedSearch = this.debounce(this.performSearch, this.debounceValue)

  async performSearch() {
    const query = this.inputTarget.value

    const [pathName, queryString] = this.urlValue.split('?')
    const newUrl = this.buildSearchUrl(pathName, queryString, query)

    // Replace current URL without affecting browser history
    if (!queryString || !queryString.includes('turbo_frame')) {
      window.history.replaceState({}, '', newUrl)
    }

    try {
      // Show a spinner if the request takes longer than 300ms (after debounce)
      this.#startSpinnerTimer()

      await get(newUrl, {
        responseKind: 'turbo-stream',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
          'X-Search-Request': 'resource-search-controller',
        },
      })
    } catch (error) {
      // Silently fail; network errors are surfaced via Turbo stream failures
    } finally {
      this.#stopSpinner()
    }
  }

  // Utility function to build search URL with query and pagination reset
  buildSearchUrl(pathname, currentSearch, query) {
    const searchParams = new URLSearchParams(currentSearch)

    if (query) {
      searchParams.set('q', query)
    } else {
      searchParams.delete('q')
    }

    searchParams.set('page', '1')

    return `${pathname}?${searchParams.toString()}`
  }

  debounce(func, wait) {
    let timeout

    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func.apply(this, args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }

  // Private

  #spinnerTimer = null

  #spinnerEl = null

  #spinnerDelayMs = 500

  #startSpinnerTimer() {
    this.#clearSpinnerTimer()
    this.#spinnerTimer = setTimeout(() => this.#showSpinner(), this.#spinnerDelayMs)
  }

  #clearSpinnerTimer() {
    if (this.#spinnerTimer) {
      clearTimeout(this.#spinnerTimer)
      this.#spinnerTimer = null
    }
  }

  #showSpinner() {
    // Add a body class to signal loading (used by tests/possible styles)
    document.body.classList.add('search-loading')

    this.overlayTarget.classList.add('is-active')
    this.#spinnerEl = this.overlayTarget
  }

  #removeSpinner() {
    document.body.classList.remove('search-loading')
    if (this.#spinnerEl) this.#spinnerEl.classList.remove('is-active')
    this.#spinnerEl = null
  }

  #stopSpinner() {
    this.#clearSpinnerTimer()
    this.#removeSpinner()
  }
}
