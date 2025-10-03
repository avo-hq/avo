import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'overlay']

  toggle() {
    if (!this.hasContentTarget) return

    // Toggle blur utility class
    this.contentTarget.classList.toggle('blur-md')

    // Toggle overlay visibility in sync
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle('hidden')
    }
  }
}
