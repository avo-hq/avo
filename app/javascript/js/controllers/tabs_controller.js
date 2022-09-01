import { AttributeObserver } from '@stimulus/mutation-observers'
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

  targetTab(id) {
    return this.tabTargets.find((element) => element.dataset.tabsIdParam === id)
  }

  targetTabPanel(id) {
    return this.tabPanelTargets.find((element) => element.dataset.tabId === id)
  }

  changeTab(e) {
    e.preventDefault()

    const { params } = e
    const { id } = params

    this.setTheTargetPanelHeight(id)

    this.hideTabs()
    this.showTab(id)
    this.markTabLoaded(id)

    this.activeTabValue = id
  }

  /**
   * Sets the target container height to the previous panel height so we don't get jerky tab changes.
   */
  setTheTargetPanelHeight(id) {
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
    const observer = new AttributeObserver(this.targetTabPanel(id), 'busy', {
      elementUnmatchedAttribute: () => {
        // The content is not available in an instant so delay the height reset a bit.
        setTimeout(() => {
          this.targetTab(id).style.height = ''
        }, 300)
        if (observer) observer.stop()
      },
    })
    observer.start()
  }

  markTabLoaded(id) {
    this.targetTabPanel(id).dataset.loaded = true
  }

  showTab(id) {
    this.tabPanelTargets.forEach((element) => {
      if (element.dataset.tabId === id) {
        element.classList.remove('hidden')
      }
    })
  }

  hideTabs() {
    this.tabPanelTargets.map((element) => element.classList.add('hidden'))
  }
}
