import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['element'];

  focus({ params }) {
    const element = this.context.element.querySelector(params.selector)
    if (this.element) {
      element.focus()
    }
  }
}
