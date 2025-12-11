import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["tabPanel", "tabButton"]

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
      this.updateActiveTabButtons(groupId)
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

    this.hideAllTabs()
    this.revealTabByName(tabName)
    this.updateActiveTabButtons(tabName)
  }

  // We're revealing the new tab that's lazy loaded by Turbo.
  revealTabByName(name) {
    this.getTabByName(name).classList.remove('hidden')
  }

  hideAllTabs() {
    this.tabPanelTargets.map((element) => element.classList.add('hidden'))
  }

  updateActiveTabButtons(tabName) {
    if (!this.hasTabButtonTarget) return;

    this.tabButtonTargets.forEach((button) => {
      const isActive = button.dataset.tabId === tabName;

      // Update button accessibility attributes
      button.setAttribute("aria-selected", isActive);
      button.setAttribute("tabindex", isActive ? "0" : "-1");

      // Toggle button classes
      this.toggleTabClasses(button, isActive);

      // Toggle wrapper classes (for scope variant)
      const wrapper = button.closest(".avo-tab-wrapper--scope");
      if (wrapper) {
        this.toggleTabClasses(wrapper, isActive, button);
      }
    });
  }

  toggleTabClasses(element, isActive, sourceElement = element) {
    const activeClass = sourceElement.dataset.tabActiveClass;
    const inactiveClass = sourceElement.dataset.tabInactiveClass;

    if (activeClass) element.classList.toggle(activeClass, isActive);
    if (inactiveClass) element.classList.toggle(inactiveClass, !isActive);
  }
}
