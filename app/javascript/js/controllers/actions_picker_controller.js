import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['resourceAction', 'standaloneAction']

  static classes = ['enabled', 'disabled']

  target = {}

  get targetIsDisabled() {
    return this.target.dataset.disabled === 'true'
  }

  get actionsShowTurboFrame() {
    return document.querySelector('turbo-frame#actions_show')
  }

  enableTarget() {
    console.log('enableTarget')
    if (this.targetIsDisabled) {
      this.target.classList.remove(...this.disabledClasses)
      this.target.classList.add(...this.enabledClasses)
      this.target.dataset.disabled = false
    }
  }

  disableTarget() {
    console.log('disableTarget')
    this.target.classList.remove(...this.enabledClasses)
    this.target.classList.add(...this.disabledClasses)
    this.target.dataset.disabled = true
  }

  visitAction(event) {
    this.target = event.target

    if (this.targetIsDisabled) {
      event.preventDefault()

      return
    }

    this.disableTarget()
    const that = this
    setTimeout(() => {
      this.actionsShowTurboFrame.loaded.then(() => that.enableTarget(that.target))
    }, 1)
  }
}
