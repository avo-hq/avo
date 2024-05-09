import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

function updateQueryParam(url, key, value) {
  const uri = new URI(url)
  uri.setQuery(key, value)

  return uri.toString()
}

function getDateParam(url) {
  const queryString = url.split('?')[1]
  const params = new URLSearchParams(queryString)

  return params.get('date')
}

export default class extends Controller {
  static targets = ['card', 'cardsElements']

  interval

  get parentTurboFrame() {
    return this.context.scope.element.closest('turbo-frame')
  }

  get refreshInterval() {
    if (this.cardTarget.dataset.refreshEvery) {
      return parseInt(this.cardTarget.dataset.refreshEvery, 10) * 1000
    }

    return undefined
  }

  connect() {
    if (this.refreshInterval) {
      this.interval = setInterval(() => {
        this.parentTurboFrame.reload()
      }, this.refreshInterval)
    }
  }

  cardTargetDisconnected() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }

  updateCards(event) {
    const href = event.currentTarget.getAttribute('href')
    const dateParam = getDateParam(href)
    if (this.cardsElementsTarget) {
      const frames = this.cardsElementsTarget.querySelectorAll('turbo-frame')
      frames.forEach((frame) => {
        let src = frame.getAttribute('src')
        src = updateQueryParam(src, 'date', dateParam)
        frame.setAttribute('src', src)
      })
    }
  }
}
