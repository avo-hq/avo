import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'moreContentButton', 'lessContentButton']

  static values = { alwaysShow: Boolean }

  connect() {
    if (this.alwaysShowValue) return // Ignore checking when alwaysShow is true

    this.checkContentHeight()
  }

  checkContentHeight() {
    const contentHeight = this.contentTarget.scrollHeight

    if (contentHeight > 50) {
      this.moreContentButtonTarget.classList.remove('hidden')
    }
  }

  toggleContent() {
    this.contentTarget.classList.toggle('hidden')
    this.toggleButtons()
  }

  toggleButtons() {
    this.moreContentButtonTarget.classList.toggle('hidden')
    this.lessContentButtonTarget.classList.toggle('hidden')
  }
}
