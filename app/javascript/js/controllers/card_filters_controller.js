import { Controller } from '@hotwired/stimulus'
import URI from 'urijs'

export default class extends Controller {
  static targets = ['cards']

  updateCards(event) {
    this.cardsTargets.forEach((frame) => {
      // Add date param to the existing frame.src
      console.log(frame.src)
      frame.src = new URI(frame.src).setQuery('global_range[date]', event.target.dataset.days).toString()
      console.log(frame.src)
    })
  }
}
