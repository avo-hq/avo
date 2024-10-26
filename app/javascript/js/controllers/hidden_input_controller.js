import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content', 'hideContentLink', 'showContentLink']

  showContent(event) {
    this.contentTarget.classList.remove('hidden') // Make content visible
    this.showContentLinkTarget.classList.add('hidden') // Hide "Show content" link
    this.hideContentLinkTarget.classList.remove('hidden') // Show "Hide content" link
  }

  hideContent(event) {
    this.contentTarget.classList.add('hidden') // Hide content
    this.hideContentLinkTarget.classList.add('hidden') // Hide "Hide content" link
    this.showContentLinkTarget.classList.remove('hidden') // Show "Show content" link
  }
}
