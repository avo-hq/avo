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
  // rows — exactly what view-transition-name pairing handles. The name is
  // applied only for the duration of the transition so multiple tab
  // groups on a page never collide.
  switchTab(name) {
    const swap = () => {
      this.hideAllTabs()
      this.revealTabByName(name)
    }

    const oldItem = this.element.querySelector('[data-tabs-target="tabPanel"]:not(.hidden) .tabs__indicator')
    const newItem = this.getTabByName(name)?.querySelector('.tabs__indicator')

    if (!document.startViewTransition || !oldItem || !newItem || oldItem === newItem) {
      swap()

      return
    }

    oldItem.style.viewTransitionName = 'tabs-active-item'
    // Marker class scopes the "disable root crossfade" CSS to our transition
    // so it can't interfere with other (e.g. Turbo) view transitions.
    document.documentElement.classList.add('tabs-view-transition')

    const transition = document.startViewTransition(() => {
      oldItem.style.viewTransitionName = ''
      newItem.style.viewTransitionName = 'tabs-active-item'
      swap()
    })

    transition.finished.finally(() => {
      newItem.style.viewTransitionName = ''
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
