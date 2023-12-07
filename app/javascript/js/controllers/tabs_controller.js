import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tabPanel'];

  static values = {
    view: String,
    activeTab: String,
    groupId: String,
  };

  connect() {
    this.selectCurrentTab()
  }

  selectCurrentTab() {
    const params = {}
    Array.from(new URL(window.location).searchParams.entries()).forEach((item) => params[item[0]] = item[1])

    // LocalStorage value
    const lsValue = window.Avo.localStorage.get(`resources.user.tabgroups.${this.groupIdValue}.selectedTab`)

    // if this tab group has a param in the address, select it
    if (params[this.groupParam(this.groupIdValue)]) {
      this.hideAllTabs()
      this.revealTabByName(decodeURIComponent(params[this.groupParam(this.groupIdValue)]))
    } else if (lsValue) {
      this.hideAllTabs()
      this.revealTabByName(decodeURIComponent(lsValue))
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
    const {params} = e
    const {groupId, tabName, resourceName} = params
    const key = `resources.${resourceName}.tabgroups.${groupId}.selectedTab`

    const u = new URL(window.location);
    u.searchParams.set(this.groupParam(groupId), encodeURIComponent(tabName));
    history.replaceState(null, '', u.pathname+u.search);

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
