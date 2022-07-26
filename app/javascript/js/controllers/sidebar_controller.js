import { Controller } from '@hotwired/stimulus'
import { enter, leave, toggle } from 'el-transition'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['sidebar', 'mobileSidebar', 'mainArea']

  static values = {
    open: Boolean,
  }

  get cookieKey() {
    return `${window.Avo.configuration.cookies_key}.sidebar.open`
  }

  get sidebarOpen() {
    return Cookies.get(this.cookieKey) === '1'
  }

  set cookie(state) {
    Cookies.set(this.cookieKey, state === true ? 1 : 0)
  }

  markSidebarClosed() {
    Cookies.set(this.cookieKey, '0')
    this.openValue = false
    leave(this.sidebarTarget)
    this.mainAreaTarget.classList.remove('sidebar-open')
  }

  markSidebarOpen() {
    Cookies.set(this.cookieKey, '1')
    this.openValue = true
    enter(this.sidebarTarget)
    this.mainAreaTarget.classList.add('sidebar-open')
  }

  toggleSidebar() {
    if (this.openValue) {
      this.markSidebarClosed()
    } else {
      this.markSidebarOpen()
    }
  }

  toggleSidebarOnMobile() {
    toggle(this.mobileSidebarTarget)
  }
}
