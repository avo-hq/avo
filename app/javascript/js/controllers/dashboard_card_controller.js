import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['card'];

  interval;

  get parentTurboFrame() {
    return this.context.scope.element.closest('turbo-frame')
  }

  get refreshInterval() {
    if (this.cardTarget.dataset.refreshEvery) {
      return parseInt(this.cardTarget.dataset.refreshEvery, 10) * 1000
    }

    return undefined
  }

  connect() {
    if (this.refreshInterval) {
      this.interval = setInterval(() => {
        this.parentTurboFrame.reload()
      }, this.refreshInterval)
    }
  }

  cardTargetDisconnected() {
    if (this.interval) {
      clearInterval(this.interval)
    }
  }
}
