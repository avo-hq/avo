import { AttributeObserver } from '@stimulus/mutation-observers'
import { Controller } from '@hotwired/stimulus'
import { castBoolean } from '../helpers/cast_boolean'

export default class extends Controller {
  static targets = ['tab'];

  static values = {
    activeTab: String,
  };

  get currentTab() {
    return this.tabTargets.find(
      (element) => element.dataset.tabId === this.activeTabValue,
    )
  }

  targetTab(id) {
    return this.tabTargets.find((element) => element.dataset.tabId === id)
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
    // We don't need to add a height to this panel because it was loaded before
    if (castBoolean(this.targetTab(id).dataset.loaded)) {
      return
    }

    // Get the height of the active panel
    const { height } = this.currentTab.getBoundingClientRect()
    // Set it to the target panel
    this.targetTab(id).style.height = `${height}px`

    // Wait until the panel loaded it's content and then remove the forced height
    const observer = new AttributeObserver(this.targetTab(id), 'busy', {
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
    this.targetTab(id).dataset.loaded = true
  }

  showTab(id) {
    this.tabTargets.forEach((element) => {
      if (element.dataset.tabId === id) {
        element.classList.remove('hidden')
      }
    })
    // this.tabTargets.map((element) => element.clasList.add('hidden'))
  }

  hideTabs() {
    this.tabTargets.map((element) => element.classList.add('hidden'))
  }
}
