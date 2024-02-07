import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  refresh() {
    const element = this.context.scope.element.closest('turbo-frame')
    this.element.querySelector('svg').classList.add('animate-spin')
    if (element) {
      element.reload()
    } else {
      console.error(
        `Element with ID '${this.turboFrameIdValue}' not found.`,
      )
    }
  }
}
