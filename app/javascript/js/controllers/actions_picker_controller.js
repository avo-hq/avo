import { AttributeObserver } from '@stimulus/mutation-observers'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['resourceAction', 'standaloneAction']

  target = {}

  enableTarget() {
    if (this.targetIsDisabled(this.target)) {
      this.target.classList.remove('cursor-wait', 'text-gray-500', 'hover:bg-blue-300')
      this.target.classList.add('text-gray-700', 'hover:bg-blue-500')
      this.target.dataset.disabled = false
    }
  }

  disableTarget() {
    this.target.classList.add('cursor-wait', 'text-gray-500', 'hover:bg-blue-300')
    this.target.classList.remove('text-gray-700', 'hover:bg-blue-500')
    this.target.dataset.disabled = true
  }

  targetIsDisabled() {
    return this.target.dataset.disabled === 'true'
  }

  visitAction(event) {
    this.target = event.target

    if (this.targetIsDisabled()) {
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
