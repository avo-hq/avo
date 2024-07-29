import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

// Detect whether an element is in view inside a parent element.
// Original here: https://gist.github.com/jjmu15/8646226
function isInViewport(element, parentElement) {
  const rect = element.getBoundingClientRect()
  const html = document.documentElement
  const parent = parentElement.getBoundingClientRect()

  return (
    rect.top >= 0
    && rect.left >= 0
    && rect.bottom <= (parent.height || window.innerHeight || html.clientHeight)
    && rect.right <= (parent.width || window.innerWidth || html.clientWidth)
  )
}

// Used on initial page load to scroll to the first active sidebar item if it's not in view.
function scrollSidebarMenuItemIntoView() {
  const activeSidebarItem = document.querySelector('.avo-sidebar .mac-styled-scrollbar a.active')
  const sidebarScrollingArea = document.querySelector('.avo-sidebar .mac-styled-scrollbar')
  if (activeSidebarItem && !isInViewport(activeSidebarItem, sidebarScrollingArea)) {
    activeSidebarItem.scrollIntoView({ block: 'end', inline: 'nearest' })
  }
}

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

  get sidebarScrollPosition() {
    return window.Avo.localStorage.get('sidebar.sidebarScrollPosition')
  }

  set sidebarScrollPosition(value) {
    window.Avo.localStorage.set('sidebar.sidebarScrollPosition', value)
  }

  set cookie(state) {
    Cookies.set(this.cookieKey, state === true ? 1 : 0)
  }

  connect() {
    this.attachScrollVisibilityAnchor()

    // Restore sidebar scroll position
    if (this.sidebarScrollPosition && window.Avo.configuration.preserve_sidebar_scroll) {
      document.querySelector('.avo-sidebar .mac-styled-scrollbar').scrollTo({
        top: this.sidebarScrollPosition,
        behavior: 'instant',
      })
    }
    this.rememberScrollPosition()
  }

  rememberScrollPosition() {
    let handler

    document.addEventListener('turbo:visit', handler = () => {
      // Remeber sidebar scroll position before changing pages.
      this.sidebarScrollPosition = document.querySelector('.avo-sidebar .mac-styled-scrollbar').scrollTop
      // remove event handler after disconnection
      document.removeEventListener('turbo:visit', handler)
    })
  }

  attachScrollVisibilityAnchor() {
    if (window.Avo.configuration.focus_sidebar_menu_item) {
      scrollSidebarMenuItemIntoView()
    }
  }

  toggleSidebar() {
    this.mainAreaTarget.classList.toggle('sidebar-open')
    const value = Cookies.get(this.cookieKey)
    Cookies.set(this.cookieKey, value === '1' ? '0' : '1')
  }
}
