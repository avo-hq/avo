import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['sidebar']

  toggleSidebar() {
    this.sidebarTarget.classList.toggle('hidden')
  }
}
