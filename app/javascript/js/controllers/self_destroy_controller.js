import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  destroy() {
    this.context.element.remove()
  }
}
