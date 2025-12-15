import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tabPanel', 'tabButton']

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
    Array.from(new URL(window.location).searchParams.entries()).forEach(
      ([key, value]) => {
        params[key] = value
      },
    )

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

    // Remove keyboard focus class on mouse click
    this.removeKeyboardFocusClass()

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
    if (!this.hasTabButtonTarget) return

    this.tabButtonTargets.forEach((button) => {
      const isActive = button.dataset.tabId === tabName
      const isFocused = document.activeElement === button

      button.setAttribute('aria-selected', isActive)

      if (isActive || isFocused) {
        button.setAttribute('tabindex', '0')
      } else {
        button.setAttribute('tabindex', '-1')
      }

      this.toggleTabClasses(button, isActive)

      const wrapper = button.closest('.tabs__item-wrapper--scope')
      if (wrapper) {
        this.toggleTabClasses(wrapper, isActive, button)
      }
    })
  }

  toggleTabClasses(element, isActive, sourceElement = element) {
    const activeClass = sourceElement.dataset.tabActiveClass
    const inactiveClass = sourceElement.dataset.tabInactiveClass

    if (activeClass) element.classList.toggle(activeClass, isActive)
    if (inactiveClass) element.classList.toggle(inactiveClass, !isActive)
  }

  handleKeyDown(e) {
    const currentTab = e.currentTarget
    const tabs = this.getEnabledTabs()
    const currentIndex = tabs.indexOf(currentTab)

    if (currentIndex === -1) return

    let targetTab = null
    let shouldPreventDefault = false

    switch (e.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        targetTab = tabs[(currentIndex + 1) % tabs.length]
        shouldPreventDefault = true
        break

      case 'ArrowLeft':
      case 'ArrowUp':
        targetTab = tabs[(currentIndex - 1 + tabs.length) % tabs.length]
        shouldPreventDefault = true
        break

      case 'Home':
        targetTab = tabs[0]
        shouldPreventDefault = true
        break

      case 'End':
        targetTab = tabs[tabs.length - 1]
        shouldPreventDefault = true
        break

      case 'Enter':
      case ' ':
        if (currentTab.dataset.tabId) {
          this.activateTab(currentTab)
          shouldPreventDefault = true
        }
        break
    }

    if (shouldPreventDefault) {
      e.preventDefault()
    }

    if (targetTab) {
      this.focusTab(targetTab)
    }
  }

  getEnabledTabs() {
    return this.tabButtonTargets.filter((button) => {
      const disabled =        button.getAttribute('aria-disabled') === 'true'
        || button.hasAttribute('disabled')

      return !disabled
    })
  }

  focusTab(tabButton) {
    // Remove focus class from all tabs first
    this.removeKeyboardFocusClass()

    // Add keyboard focus class and focus the tab
    tabButton.classList.add('tabs__item--focused')
    tabButton.setAttribute('tabindex', '0')
    tabButton.focus()
  }

  removeKeyboardFocusClass() {
    // Remove keyboard focus class from all tabs
    this.tabButtonTargets.forEach((button) => {
      button.classList.remove('tabs__item--focused')
    })
  }

  // Handle blur event - remove focus class when tab loses focus
  handleBlur(e) {
    e.currentTarget.classList.remove('tabs__item--focused')
  }

  // Handle mousedown - remove focus class immediately on mouse interaction
  handleMouseDown(e) {
    // Remove focus class when mouse is used (prevents focus ring on click)
    this.removeKeyboardFocusClass()
  }

  // NEW: Activate a tab programmatically
  activateTab(tabButton) {
    const { tabId } = tabButton.dataset
    if (!tabId) return

    const syntheticEvent = {
      preventDefault: () => {},
      params: {
        groupId: this.groupIdValue,
        tabName: tabId,
        resourceName: this.resourceNameValue,
      },
    }

    this.changeTab(syntheticEvent)
  }
}
