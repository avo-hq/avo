import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  refresh() {
    const frame = this.context.scope.element.closest('turbo-frame')
    this.element.querySelector('svg').classList.add('animate-spin')
    if (frame) {
      frame.reload()
    } else {
      console.error(
        `Element with ID '${this.turboFrameIdValue}' not found.`,
      )
    }
  }
}
