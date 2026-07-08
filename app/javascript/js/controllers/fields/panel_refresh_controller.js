import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  refresh() {
    const frame = this.context.scope.element.closest('turbo-frame')
    this.element.querySelector('svg').classList.add('animate-spin')
    if (frame) {
      frame.classList.add('opacity-50')
      frame.addEventListener('turbo:frame-load', () => {
        frame.classList.remove('opacity-50')
      }, { once: true })
      frame.reload()
    } else {
      console.error(
        `Element with ID '${this.turboFrameIdValue}' not found.`,
      )
    }
  }
}
