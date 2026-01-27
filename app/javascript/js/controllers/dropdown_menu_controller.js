import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["dropdownMenuComponent"]

  connect() {
    this.isOpen = false

    if (this.hasDropdownMenuComponentTarget) {
      // Listen to clicks on the dialog itself (backdrop)
      this.dropdownMenuComponentTarget.addEventListener('click', (event) => {
        // If clicked directly on the dialog (not its children), it's the backdrop
        if (event.target === this.dropdownMenuComponentTarget) {
          this.close()
        }
      })

      this.dropdownMenuComponentTarget.addEventListener('close', () => {
        this.isOpen = false
      })
    }
  }

    toggle(event) {
    if (event) {
      event.stopPropagation()
      event.preventDefault()
      event.stopImmediatePropagation()
    }
    if (this.hasDropdownMenuComponentTarget) {
      if (this.isOpen) {
        this.close()
      } else {
        this.show()
      }
    }
  }

  show() {
    if (this.hasDropdownMenuComponentTarget) {
      this.dropdownMenuComponentTarget.show()
      this.isOpen = true
    }
  }

  close() {
    if (this.hasDropdownMenuComponentTarget) {
      this.dropdownMenuComponentTarget.close()
      this.isOpen = false
    }
  }

  preventClose(event) {
    event.stopPropagation()
  }
}
