import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tab']

  // connect() {
  //   console.log('tabs_controller')
  // }

  changeTab(e) {
    e.preventDefault()
    const { params } = e
    const { id } = params
    console.log('params->', params, id, this.tabTargets)

    this.hideTabs()
    this.showTab(id)
  }

  showTab(id) {
    console.log('showTab->', id, this.tabTargets)
    this.tabTargets.map((element) => {
      if (element.dataset.tabId === id) {
        element.classList.remove('hidden')
        console.log('showing->', id)
      }
    })
    // this.tabTargets.map((element) => element.clasList.add('hidden'))
  }

  hideTabs() {
    this.tabTargets.map((element) => element.classList.add('hidden'))
  }
}
