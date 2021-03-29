import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['content']

  showContent(event) {
    this.contentTarget.classList.toggle('hidden')
    event.target.classList.add('hidden')
  }
}
