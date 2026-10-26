import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  refresh() {
    const frame = this.context.scope.element.closest('turbo-frame')
    // The tabler refresh icon's arrows point counterclockwise, so the spin must run in reverse to match.
    this.element.querySelector('svg').classList.add('animate-spin', '[animation-direction:reverse]')
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
