import { Controller } from '@hotwired/stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['input']

  static values = {
    debounce: { type: Number, default: 300 },
  }

  search() {
    this.debouncedSearch()
  }

  debouncedSearch = this.debounce(this.performSearch, this.debounceValue)

  async performSearch() {
    const query = this.inputTarget.value

    // Check if we're inside a turbo frame with a src attribute
    const turboFrame = this.findTurboFrameWithSrc()

    if (turboFrame) {
      await this.searchInTurboFrame(turboFrame, query)
    } else {
      await this.updateCurrentPage(query)
    }
  }

  findTurboFrameWithSrc() {
    // Look for a parent turbo-frame element with a src attribute
    let element = this.element
    while (element && element !== document.body) {
      if (element.tagName === 'TURBO-FRAME' && element.hasAttribute('src')) {
        return element
      }
      element = element.parentElement
    }

    return null
  }

  async searchInTurboFrame(turboFrame, query) {
    const currentSrc = turboFrame.getAttribute('src')
    const { origin } = window.location
    const srcUrl = new URL(currentSrc, origin)
    const requestUrl = this.buildSearchUrl(srcUrl.pathname, srcUrl.search, query)

    await this.performSearchRequest(requestUrl)
  }

  async updateCurrentPage(query) {
    const { href, search } = window.location
    const currentUrl = new URL(href)
    const newUrl = this.buildSearchUrl(currentUrl.pathname, search, query)

    // Replace current URL without affecting browser history
    window.history.replaceState({}, '', newUrl)

    await this.performSearchRequest(newUrl)
  }

  // Utility function to build search URL with query and pagination reset
  buildSearchUrl(pathname, currentSearch, query) {
    const searchParams = new URLSearchParams(currentSearch)

    this.updateSearchParams(searchParams, query)
    this.resetPagination(searchParams)

    return `${pathname}?${searchParams.toString()}`
  }

  // Utility function to update search parameters
  updateSearchParams(searchParams, query) {
    if (query) {
      searchParams.set('q', query)
    } else {
      searchParams.delete('q')
    }
  }

  // Utility function to reset pagination
  resetPagination(searchParams) {
    searchParams.set('page', '1')
  }

  // Utility function to perform the search request with consistent headers and error handling
  async performSearchRequest(url) {
    try {
      await get(url, {
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
