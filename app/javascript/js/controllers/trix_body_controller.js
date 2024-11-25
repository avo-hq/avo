import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'moreContentButton', 'lessContentButton']

  connect() {
    this.checkContentHeight()
  }

  checkContentHeight() {
    const contentHeight = this.contentTarget.scrollHeight

    if (contentHeight > 50 && this.hasMoreContentButtonTarget) {
      this.moreContentButtonTarget.classList.remove('hidden')
    }
  }

  toggleContent() {
    this.contentTarget.classList.toggle('hidden')
    this.toggleButtons()
  }

  toggleButtons() {
    if (this.hasMoreContentButtonTarget) this.moreContentButtonTarget.classList.toggle('hidden')
    if (this.hasLessContentButtonTarget) this.lessContentButtonTarget.classList.toggle('hidden')
  }
}
