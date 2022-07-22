import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['sidebar', 'mainArea']

  static values = {
    open: Boolean,
  }

  get cookieKey() {
    return `${window.Avo.configuration.cookies_key}.sidebar.open`
  }

  get cookie() {
    return Cookies.get(this.cookieKey)
  }

  set cookie(state) {
    Cookies.set(this.cookieKey, state === true ? 1 : 0)
  }

  toggleSidebar() {
    if (this.cookie === '1') {
      this.cookie = false
      this.mainAreaTarget.classList.remove('sidebar-open')
    } else {
      this.cookie = true
      this.mainAreaTarget.classList.add('sidebar-open')
    }
  }

  toggleSidebarOnMobile() {
    this.sidebarTarget.classList.toggle('hidden')
  }
}
