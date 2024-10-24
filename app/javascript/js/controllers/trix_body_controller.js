import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'moreContentButton', 'lessContentButton']

  toggleContent() {
    this.contentTarget.classList.toggle('hidden')
    this.toggleButtons()
  }

  toggleButtons() {
    this.moreContentButtonTarget.classList.toggle('hidden')
    this.lessContentButtonTarget.classList.toggle('hidden')
  }
}
