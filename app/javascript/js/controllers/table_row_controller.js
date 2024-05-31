import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  visitRecord(event) {
    if (event.type === 'click') {
      const isLinkOrButton = event.target.closest('a, button, svg')

      if (isLinkOrButton) {
        return // Don't navigate if a link or button is clicked
      }

      this.#executeTheVisit(event)
    }
  }

  #executeTheVisit(event) {
    const row = event.target.closest('tr')
    if (row && row.dataset.visitPath) {
      window.Turbo.visit(row.dataset.visitPath)
    }
  }
}
