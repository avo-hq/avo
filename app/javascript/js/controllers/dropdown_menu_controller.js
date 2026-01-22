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
          console.log('Clicked backdrop, closing')
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
    console.log('toggle')
    if (this.hasDropdownMenuComponentTarget) {
      console.log('dropdownMenuComponentTarget.open', this.isOpen)
      if (this.isOpen) {
        console.log('>>> CLOSING')
        this.close()
      } else {
        console.log('>>> OPENING')
        this.show()
      }
    }
  }

  show() {
    console.log('show')
    if (this.hasDropdownMenuComponentTarget) {
      console.log('dropdownMenuComponentTarget', this.dropdownMenuComponentTarget)
      this.dropdownMenuComponentTarget.show()
      this.isOpen = true
    }
  }

  close() {
    console.log('close')
    if (this.hasDropdownMenuComponentTarget) {
      console.log('dropdownMenuComponentTarget', this.dropdownMenuComponentTarget)
      this.dropdownMenuComponentTarget.close()
      this.isOpen = false
    }
  }

  preventClose(event) {
    console.log('preventClose')
    event.stopPropagation()
  }
}
