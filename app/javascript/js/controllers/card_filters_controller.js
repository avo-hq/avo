import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

function updateQueryParam(url, key, value) {
  const uri = new URI(url)
  uri.setQuery(key, value)

  return uri.toString()
}

function getDateParam(url) {
  const uri = new URI(url)
  const { date } = uri.search(true)

  return date
}

export default class extends Controller {
  static targets = ['cardsElements']

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
