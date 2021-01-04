import { Controller } from 'stimulus'

export default class extends Controller {
  greet() {
    this.element.textContent = 'Hello World!'
  }
}
