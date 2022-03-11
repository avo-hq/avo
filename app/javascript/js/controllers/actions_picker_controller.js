import { AttributeObserver } from '@stimulus/mutation-observers'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['resourceAction', 'standaloneAction']

  static classes = ['enabled', 'disabled']

  target = {}

  get targetIsDisabled() {
    return this.target.dataset.disabled === 'true'
  }

  enableTarget() {
    if (this.targetIsDisabled) {
      this.target.classList.remove(...this.disabledClasses)
      this.target.classList.add(...this.enabledClasses)
      this.target.dataset.disabled = false
    }
  }

  disableTarget() {
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

    const observer = new AttributeObserver(document.querySelector('turbo-frame#actions_show'), 'busy', {
      elementUnmatchedAttribute: () => {
        this.enableTarget(this.target)
        if (observer) observer.stop()
      },
    })
    observer.start()
  }
}
