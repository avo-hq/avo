import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  refresh() {
    const button = this.element
    button.classList.add('animate-spin')
    const element = this.context.scope.element.closest('turbo-frame')
    if (element) {
      element.addEventListener('turbo:before-fetch-response', () => {
        button.classList.remove('animate-spin')
      })
      element.reload()
    } else {
      console.error(
        `Element with ID '${this.turboFrameIdValue}' not found.`,
      )
    }
  }
}
