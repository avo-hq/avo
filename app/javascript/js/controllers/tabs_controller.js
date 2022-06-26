import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tab']

  connect() {
    console.log('tabs_controller')
  }

  changeTab(e) {
    e.preventDefault()
    console.log('tabChange->', e)
    const { params } = e
    const { id } = params
    console.log('params->', params, id, this.tabTargets)

    this.hideTabs()
    this.showTab(id)
  }

  showTab(id) {
    console.log('showTab->', id, this.tabTargets)
    this.tabTargets.map((element) => {
      console.log('element.dataset.tabId->', element.dataset.tabId)
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
