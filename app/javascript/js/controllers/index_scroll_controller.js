import { Controller } from '@hotwired/stimulus'
import { saveScroll, takeScroll } from '../index_state'

// Brings the user back to where they were on an index page when they go back to it, with the browser's
// Back button or the "Go back" link, which loads a fresh page that would otherwise open at the top.
export default class extends Controller {
  connect() {
    this.boundSave = this.#save.bind(this)
    document.addEventListener('turbo:before-visit', this.boundSave)

    // Turbo may show a cached preview first; restore on the real page so the position isn't spent.
    if (document.documentElement.hasAttribute('data-turbo-preview')) return

    const position = takeScroll(window.location.href)

    if (position !== null) {
      this.#restore(position)
    }
  }

  disconnect() {
    document.removeEventListener('turbo:before-visit', this.boundSave)
  }

  #save() {
    saveScroll(window.location.href, window.scrollY)
  }

  #restore(position) {
    const scroll = () => {
      if (!this.element.isConnected) return

      requestAnimationFrame(() => window.scrollTo(0, position))
    }

    // A lazy-loaded index has no rows to scroll to until its frame loads.
    const pendingFrame = this.element.querySelector('turbo-frame[data-controller~="resource-index"][src]:not([complete])')

    if (pendingFrame) {
      pendingFrame.addEventListener('turbo:frame-load', scroll, { once: true })
    } else {
      // Turbo scrolls a new page to the top as it finishes the visit, so wait for that.
      document.addEventListener('turbo:load', scroll, { once: true })
    }
  }
}
