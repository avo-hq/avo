import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['input']

  static values = {
    debounce: { type: Number, default: 300 },
    url: String,
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
    if (!queryString.includes('turbo_frame')) {
      window.history.replaceState({}, '', newUrl)
    }

    try {
      await get(newUrl, {
        responseKind: 'turbo-stream',
        headers: {
          Accept: 'text/vnd.turbo-stream.html',
        },
      })
    } catch (error) {
      console.error('Error performing search:', error)
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
}
