import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['input']

  static values = {
    debounce: { type: Number, default: 300 },
  }

  connect() {
    console.log('Resource search controller connected')
  }

  search() {
    this.debouncedSearch()
  }

  debouncedSearch = this.debounce(this.performSearch, this.debounceValue)

  async performSearch() {
    const query = this.inputTarget.value
    const currentUrl = new URL(window.location.href)

    // Get existing search params
    const searchParams = new URLSearchParams(window.location.search)

    // Update the search parameter
    if (query) {
      searchParams.set('q', query)
    } else {
      searchParams.delete('q')
    }

    // Reset to first page when searching
    searchParams.set('page', '1')

    // Construct the new URL with all parameters
    const newUrl = `${currentUrl.pathname}?${searchParams.toString()}`

    // Replace current URL without affecting browser history
    window.history.replaceState({}, '', newUrl)

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
