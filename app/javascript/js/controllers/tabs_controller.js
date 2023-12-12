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
    window.history.replaceState(null, '', u.pathname + u.search)

    window.Avo.localStorage.set(key, tabName)

    this.hideAllTabs()
    this.revealTabByName(tabName)
  }

  // We're revealing the new tab that's lazy loaded by Turbo.
  revealTabByName(name) {
    this.getTabByName(name).classList.remove('hidden')
  }

  hideAllTabs() {
    this.tabPanelTargets.map((element) => element.classList.add('hidden'))
  }
}
