import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['sidebar']

  connect() {
    console.log('mobile_controller', this.sidebarTarget)
  }

  toggleSidebar() {
    console.log('toggleSidebar')
    this.sidebarTarget.classList.toggle('hidden')
  }
}
