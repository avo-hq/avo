import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

// Detect whether an element is in view inside a parent element.
// Original here: https://gist.github.com/jjmu15/8646226
function isInViewport(element, parentElement) {
  if (!element || !parentElement) return false

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



  get stateCookieKey() {
    return `${window.Avo.configuration.cookies_key}.sidebar.state`
  }

  get isDesktop() {
    // Tailwind `lg` is 1024px
    return window.matchMedia('(min-width: 1024px)').matches
  }

  get isMobile() {
    return !this.isDesktop
  }

  get state() {
    const cookieState = Cookies.get(this.stateCookieKey)
    if (cookieState === 'open' || cookieState === 'collapsed' || cookieState === 'closed') {
      return cookieState
    }

    // Default: open on desktop, collapsed on mobile
    return this.isDesktop ? 'open' : 'collapsed'
  }

  get sidebarScrollPosition() {
    return window.Avo.localStorage.get('sidebar.sidebarScrollPosition')
  }

  set sidebarScrollPosition(value) {
    window.Avo.localStorage.set('sidebar.sidebarScrollPosition', value)
  }

  set state(state) {
    Cookies.set(this.stateCookieKey, state)
  }

  connect() {
    this.attachScrollVisibilityAnchor()

    const hadStateCookie = Cookies.get(this.stateCookieKey) !== undefined

    let state = this.state

    // On mobile we never keep it fully closed; fall back to icon-only.
    if (this.isMobile && state === 'closed') {
      state = 'collapsed'
    }

    // Persist default / normalized state so server can render it next time.
    if (!hadStateCookie || Cookies.get(this.stateCookieKey) !== state) {
      this.state = state
    }

    this.applyState(state)

    // Restore sidebar scroll position
    if (this.sidebarScrollPosition) {
      const scrollingArea = document.querySelector('.avo-sidebar .mac-styled-scrollbar')
      if (scrollingArea) {
        scrollingArea.scrollTo({
          top: this.sidebarScrollPosition,
          behavior: 'instant',
        })
      }
    }
    this.rememberScrollPosition()
  }

  rememberScrollPosition() {
    let handler

    document.addEventListener('turbo:visit', handler = () => {
      // Remember sidebar scroll position before changing pages.
      const scrollingArea = document.querySelector('.avo-sidebar .mac-styled-scrollbar')
      if (scrollingArea) {
        this.sidebarScrollPosition = scrollingArea.scrollTop
      }
      // remove event handler after disconnection
      document.removeEventListener('turbo:visit', handler)
    })
  }

  attachScrollVisibilityAnchor() {
    scrollSidebarMenuItemIntoView()
  }

  applyState(state) {
    this.mainAreaTarget.classList.toggle('sidebar-open', state === 'open')
    this.mainAreaTarget.classList.toggle('sidebar-collapsed', state === 'collapsed')

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle('hidden', state === 'closed')
    }

    if (this.hasMobileSidebarTarget) {
      // On mobile, "closed" is treated as collapsed by connect(); still keep the guard.
      this.mobileSidebarTarget.classList.toggle('hidden', state === 'closed')
    }
  }

  toggleSidebar() {
    // Desktop cycles: open -> collapsed -> closed -> open
    const next =
      this.state === 'open' ? 'collapsed'
      : this.state === 'collapsed' ? 'closed'
      : 'open'

    this.state = next
    this.applyState(next)
  }

  toggleSidebarOnMobile() {
    // Mobile toggles: collapsed <-> open
    const current = this.state === 'closed' ? 'collapsed' : this.state
    const next = current === 'open' ? 'collapsed' : 'open'

    if (this.hasMobileSidebarTarget && this.mobileSidebarTarget.classList.contains('hidden')) {
      this.mobileSidebarTarget.classList.remove('hidden')
      // force reflow so transitions apply
      this.mainAreaTarget.offsetHeight // eslint-disable-line no-unused-expressions
    }

    this.state = next
    this.applyState(next)
  }
}
