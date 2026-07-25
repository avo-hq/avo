import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tabPanel']

  static values = {
    view: String,
    activeTab: String,
    groupId: String,
    resourceName: String,
  }

  connect() {
    this.selectCurrentTab()
  }

  disconnect() {
    // Don't leave a held height behind (e.g. in Turbo's page cache).
    this.releaseHold?.()
  }

  selectCurrentTab() {
    const params = {}
    Array.from(new URL(window.location).searchParams.entries()).forEach(([key, value]) => { params[key] = value })

    const key = `resources.${this.resourceNameValue}.tabgroups.${this.groupIdValue}.selectedTab`

    // LocalStorage value
    const lsValue = window.Avo.localStorage.get(key)

    let groupId = null

    // if this tab group has a param in the address, select it
    if (params[this.groupParam(this.groupIdValue)]) {
      groupId = params[this.groupParam(this.groupIdValue)]
    } else if (lsValue) {
      groupId = lsValue
    }

    if (this.getTabByName(groupId)) {
      this.hideAllTabs()
      this.revealTabByName(groupId)
    }
  }

  getTabByName(id) {
    return this.tabPanelTargets.find((element) => element.dataset.tabId === id)
  }

  groupParam(groupId) {
    return encodeURIComponent(`tab-group_${groupId}`)
  }

  async changeTab(e) {
    e.preventDefault()
    const { params } = e
    const { groupId, tabName, resourceName } = params
    const key = `resources.${resourceName}.tabgroups.${groupId}.selectedTab`

    const u = new URL(window.location)
    u.searchParams.set(this.groupParam(groupId), encodeURIComponent(tabName))
    window.Turbo.navigator.history.replace({ href: u.pathname + u.search })

    window.Avo.localStorage.set(key, tabName)

    this.switchTab(tabName)
  }

  // Swap panels, morphing the active tab indicator (the accent bar under
  // the active button) from the old tab to the new one via the View
  // Transitions API. Each panel carries its own copy of the buttons row,
  // so the indicator move is really a cross-element morph between two
  // rows — exactly what view-transition-name pairing handles.
  switchTab(name) {
    const swap = () => {
      this.hideAllTabs()
      this.revealTabByName(name)
    }

    // A previous switch may still be holding the group height.
    this.releaseHold?.()

    const newPanel = this.getTabByName(name)

    // When the new panel's content hasn't loaded yet, freeze the group at
    // its current size — resizing to the small loading placeholder and then
    // again to the real content would bounce the page twice. The hold is
    // released with a single animated resize when the frame finishes
    // loading.
    const pendingFrame = newPanel?.querySelector('turbo-frame[src]:not([complete])')
    if (pendingFrame) this.holdHeight(pendingFrame)

    const oldItem = this.element.querySelector('[data-tabs-target="tabPanel"]:not(.hidden) .tabs__indicator')
    const newItem = newPanel?.querySelector('.tabs__indicator')

    if (!oldItem || !newItem || oldItem === newItem) {
      swap()

      return
    }

    this.animate(swap, { oldItem, newItem })
  }

  holdHeight(frame) {
    this.element.style.height = `${this.element.offsetHeight}px`
    this.element.style.overflow = 'clip'

    // turbo:frame-load covers success and Avo's /failed_to_load fallback for
    // 500s (which loads into the frame like regular content). The other two
    // cover responses missing the frame and network errors — without them a
    // failed load would leave the group frozen at the held height.
    const events = ['turbo:frame-load', 'turbo:frame-missing', 'turbo:fetch-request-error']

    const clear = () => {
      this.element.style.height = ''
      this.element.style.overflow = ''
    }

    const release = () => {
      events.forEach((event) => frame.removeEventListener(event, release))
      this.releaseHold = null
      this.animate(clear)
    }

    this.releaseHold = () => {
      events.forEach((event) => frame.removeEventListener(event, release))
      this.releaseHold = null
      clear()
    }

    events.forEach((event) => frame.addEventListener(event, release))
  }

  // Run a DOM mutation inside a view transition. The group container is
  // always named so its box animates to its new height (and old content
  // crossfades into the new). When indicator elements are given, they're
  // named as well so the accent bar morphs between tabs. Names are applied
  // only for the duration of the transition so multiple tab groups on a
  // page never collide.
  animate(mutate, { oldItem, newItem } = {}) {
    // Reduced motion also keeps the swap synchronous in system tests, where
    // the transition callback's timing is unreliable in headless Chrome.
    if (!document.startViewTransition || window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      mutate()

      return
    }

    if (oldItem) oldItem.style.viewTransitionName = 'tabs-active-item'
    this.element.style.viewTransitionName = 'tabs-group'
    // Marker class scopes the "disable root crossfade" CSS to our transition
    // so it can't interfere with other (e.g. Turbo) view transitions.
    document.documentElement.classList.add('tabs-view-transition')

    const transition = document.startViewTransition(() => {
      if (oldItem) oldItem.style.viewTransitionName = ''
      if (newItem) newItem.style.viewTransitionName = 'tabs-active-item'
      mutate()
    })

    transition.finished.finally(() => {
      if (newItem) newItem.style.viewTransitionName = ''
      this.element.style.viewTransitionName = ''
      document.documentElement.classList.remove('tabs-view-transition')
    })
  }

  // We're revealing the new tab that's lazy loaded by Turbo.
  revealTabByName(name) {
    this.getTabByName(name).classList.remove('hidden')
  }

  hideAllTabs() {
    this.tabPanelTargets.map((element) => element.classList.add('hidden'))
  }
}
