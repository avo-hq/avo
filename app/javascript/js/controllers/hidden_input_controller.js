import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'hideContentLink', 'showContentLink']

  showContent(event) {
    this.contentTarget.classList.toggle('hidden')
    event.target.classList.add('hidden')
    this.hideContentLinkTarget.classList.remove('hidden')
  }

  hideContent(event) {
    this.contentTarget.classList.add('hidden')
    event.target.classList.add('hidden')
    this.showContentLink.classList.remove('hidden')
  }
}
