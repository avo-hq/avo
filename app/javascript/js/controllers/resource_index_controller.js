import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  loaded() {
    this.element.dataset.turboAction = 'advance'
  }
}
