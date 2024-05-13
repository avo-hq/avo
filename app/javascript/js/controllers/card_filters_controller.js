import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

export default class extends Controller {
  static targets = ['cards']

  updateCards(event) {
    this.cardsTargets.forEach((frame) => {
      frame.src = new URI(frame.src).setQuery('date', event.target.dataset.days).toString()
    })
  }
}
