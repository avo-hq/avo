import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal']

  close() {
    this.modalTarget.remove()

    document.dispatchEvent(new Event('actions-modal:close'))
  }

  delayedClose() {
    const vm = this

    setTimeout(() => {
      vm.modalTarget.remove()
      document.dispatchEvent(new Event('actions-modal:close'))
    }, 500)
  }
}
