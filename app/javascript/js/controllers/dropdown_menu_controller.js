import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['menu']

  get isOpen() {
    return this.menuTarget.hasAttribute('open')
  }

  connect() {
    if (this.hasMenuTarget) {
      // Listen to clicks on the dialog itself (backdrop)
      this.menuTarget.addEventListener('click', (event) => {
        // If clicked directly on the dialog (not its children), it's the backdrop
        if (event.target === this.menuTarget) {
          this.menuTarget.close()
        }
      })

      this.menuTarget.addEventListener('close', () => {
        this.menuTarget.close()
      })
    }
  }

  toggle(event) {
    if (event) {
      event.stopPropagation()
      event.preventDefault()
      event.stopImmediatePropagation()
    }

    if (this.isOpen) {
      this.menuTarget.close()
    } else {
      this.menuTarget.show()
    }
  }
}
