import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["dropdownMenuComponent"]

connect() {
  this.isOpen = false

  // Bind methods so we can remove them later
  this.handleBackdropClick = this.handleBackdropClick.bind(this)
  this.handleDialogClose = this.handleDialogClose.bind(this)
  this.handleOutsideClick = this.handleOutsideClick.bind(this)

  if (this.hasDropdownMenuComponentTarget) {
    // Add event listeners with stored references
    this.dropdownMenuComponentTarget.addEventListener('click', this.handleBackdropClick)
    this.dropdownMenuComponentTarget.addEventListener('close', this.handleDialogClose)
  }
}

disconnect() {
  // Clean up event listeners
  if (this.hasDropdownMenuComponentTarget) {
    this.dropdownMenuComponentTarget.removeEventListener('click', this.handleBackdropClick)
    this.dropdownMenuComponentTarget.removeEventListener('close', this.handleDialogClose)
  }

  // Clean up document listener if it exists
  document.removeEventListener('click', this.handleOutsideClick)
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
