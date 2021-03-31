import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form']

  connect() {
    this.formTarget.submit()
  }
}
