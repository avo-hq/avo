import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['panel']

  togglePanel() {
    this.panelTarget.classList.toggle('hidden')
  }
}
