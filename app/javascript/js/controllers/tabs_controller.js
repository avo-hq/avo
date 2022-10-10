import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['tabPanel'];

  static values = {
    view: String,
    activeTab: String,
  };

  get currentTab() {
    return this.tabPanelTargets.find(
      (element) => element.dataset.tabId === this.activeTabValue,
    )
  }

  targetTabPanel(id) {
    return this.tabPanelTargets.find((element) => element.dataset.tabId === id)
  }

  async changeTab(e) {
    // Stopping the link execution.
    // We're going to reveal a lazy-loaded frame to fulfill the tab change.
    e.preventDefault()

    const { params } = e
    const { id } = params

    await this.setTheTargetPanelHeight(id)

    this.hideAllTabs()
    this.revealTab(id)
    this.markTabLoaded(id)

    this.activeTabValue = id
  }

  /**
   * Sets the target container height to the previous panel height so we don't get jerky tab changes.
   */
  async setTheTargetPanelHeight(id) {
    // Ignore this on edit.
    // All tabs are loaded beforehand, they have their own height, and the page won't jiggle when the user toggles between them.
    if (this.viewValue === 'edit' || this.viewValue === 'new') {
      return
    }

    // We don't need to add a height to this panel because it was loaded before
    if (castBoolean(this.targetTabPanel(id).dataset.loaded)) {
      return
    }

    // Get the height of the active panel
    const { height } = this.currentTab.getBoundingClientRect()
    // Set it to the target panel
    this.targetTabPanel(id).style.height = `${height}px`

    // Wait until the panel loaded it's content and then remove the forced height
    await this.targetTabPanel(id).loaded
    this.targetTabPanel(id).style.height = ''
  }

  // Marking tab as loaded so we know to skip some things the next time the user clicks on it
  markTabLoaded(id) {
    this.targetTabPanel(id).dataset.loaded = true
  }

  // We're revealing the new tab that's lazy loaded by Turbo.
  revealTab(id) {
    this.targetTabPanel(id).classList.remove('hidden')
  }

  hideAllTabs() {
    this.tabPanelTargets.map((element) => element.classList.add('hidden'))
  }
}
