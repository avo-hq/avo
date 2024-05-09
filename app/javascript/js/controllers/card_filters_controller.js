import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

function updateQueryParam(url, key, value) {
  const uri = new URI(url)
  uri.setQuery(key, value)

  return uri.toString()
}

export default class extends Controller {
  updateCards(event) {
    const dateParam = event.target.dataset.days
    const frames = this.element.querySelectorAll('turbo-frame[data-card-index]')
    frames.forEach((frame) => {
      const src = frame.getAttribute('src')
      const srcUpdated = updateQueryParam(src, 'date', dateParam)
      frame.setAttribute('src', srcUpdated)
    })
  }
}
