import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

// Sidebar states — uncomment COLLAPSED and the collapsed branch below to re-enable icon-only mode
const SIDEBAR_STATES = {
  OPEN: 'open',
  CLOSED: 'closed'
  // COLLAPSED: 'collapsed'
}

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
    const validStates = Object.values(SIDEBAR_STATES)
    // When COLLAPSED is enabled, add: SIDEBAR_STATES.COLLAPSED
    if (validStates.includes(cookieState)) {
      return cookieState
    }
    // Normalize unknown/collapsed (when collapsed is disabled) to open
    if (cookieState === 'collapsed') {
      return SIDEBAR_STATES.OPEN
    }
    return SIDEBAR_STATES.OPEN
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
    this.mainAreaTarget.classList.toggle('sidebar-open', state === SIDEBAR_STATES.OPEN)
    // When COLLAPSED is enabled, use: state === SIDEBAR_STATES.COLLAPSED
    this.mainAreaTarget.classList.toggle('sidebar-collapsed', SIDEBAR_STATES.COLLAPSED != null && state === SIDEBAR_STATES.COLLAPSED)

    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle('hidden', state === SIDEBAR_STATES.CLOSED)
    }

    if (this.hasMobileSidebarTarget) {
      this.mobileSidebarTarget.classList.toggle('hidden', state === SIDEBAR_STATES.CLOSED)
    }
  }

  toggleSidebar() {
    // Desktop: open <-> closed
    // When COLLAPSED is enabled, use: open -> collapsed -> closed -> open
    const next = this.state === SIDEBAR_STATES.OPEN ? SIDEBAR_STATES.CLOSED : SIDEBAR_STATES.OPEN
    // const next = this.state === SIDEBAR_STATES.OPEN ? SIDEBAR_STATES.COLLAPSED
    //   : this.state === SIDEBAR_STATES.COLLAPSED ? SIDEBAR_STATES.CLOSED
    //   : SIDEBAR_STATES.OPEN

    this.state = next
    this.applyState(next)
  }

  toggleSidebarOnMobile() {
    // Mobile: open <-> closed (when COLLAPSED enabled: open <-> collapsed)
    const next = this.state === SIDEBAR_STATES.OPEN ? SIDEBAR_STATES.CLOSED : SIDEBAR_STATES.OPEN
    // const next = this.state === SIDEBAR_STATES.OPEN ? SIDEBAR_STATES.COLLAPSED : SIDEBAR_STATES.OPEN

    if (this.hasMobileSidebarTarget && this.mobileSidebarTarget.classList.contains('hidden')) {
      this.mobileSidebarTarget.classList.remove('hidden')
      // force reflow so transitions apply
      this.mainAreaTarget.offsetHeight // eslint-disable-line no-unused-expressions
    }

    this.state = next
    this.applyState(next)
  }
}
