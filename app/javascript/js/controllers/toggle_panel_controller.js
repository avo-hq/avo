import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['panel']

  connect() {
    useClickOutside(this)
  }

  clickOutside() {
    this.panelTarget.classList.add('hidden')
  }

  togglePanel() {
    this.panelTarget.classList.toggle('hidden')
  }
}
