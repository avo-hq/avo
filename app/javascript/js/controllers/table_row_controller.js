import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  visitRecord(event) {
    if (event.type !== 'click') {
      return
    }

    const isLinkOrButton = event.target.closest('a, button')
    const isCheckbox = event.target.closest('input[type="checkbox"]')

    if (isLinkOrButton || isCheckbox) {
      return // Don't navigate if a link or button is clicked
    }

    const row = event.target.closest('tr')
    const url = row.dataset.visitPath

    if (!row || !url) {
      return
    }

    if (event.metaKey || event.ctrlKey) {
      this.#visitInNewTab(url)
    } else {
      this.#visitInSameTab(url)
    }
  }

  #visitInSameTab(url) {
    window.Turbo.visit(url)
  }

  #visitInNewTab(url) {
    window.open(url, '_blank').focus()
  }
}
