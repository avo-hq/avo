import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['sidebar', 'mainArea']

  static values = {
    open: Boolean,
  }

  toggleSidebar() {
    this.mainAreaTarget.classList.toggle('sidebar-visible')
  }

  toggleSidebarOnMobile() {
    this.sidebarTarget.classList.toggle('hidden')
  }
}
