import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal-size"
export default class extends Controller {
  static targets = ['container']

  static values = {
    currentWidth: String,
    currentHeight: String,
  }

  connect() {
    this.modalElement = this.element
    this.updateWidthClass(this.currentWidthValue)
    this.updateHeightClass(this.currentHeightValue)
  }

  changeWidth(event) {
    const newWidth = event.currentTarget.dataset.width
    this.updateWidthClass(newWidth)
    this.currentWidthValue = newWidth
  }

  changeHeight(event) {
    const newHeight = event.currentTarget.dataset.height
    this.updateHeightClass(newHeight)
    this.currentHeightValue = newHeight
  }

  updateWidthClass(width) {
    // Remove all modal width classes from the modal element
    this.modalElement.classList.remove(
      'modal--width-sm',
      'modal--width-md',
      'modal--width-lg',
      'modal--width-xl',
      'modal--width-2xl',
      'modal--width-3xl',
      'modal--width-4xl',
      'modal--width-full',
      'modal--width-25',
      'modal--width-50',
      'modal--width-75',
      'modal--width-100',
    )

    // Remove all width classes from the container
    this.containerTarget.classList.remove('w-sm', 'w-md', 'w-lg', 'w-xl', 'w-2xl', 'w-3xl', 'w-4xl', 'w-full')

    // Add the new modal width class to the modal element
    this.modalElement.classList.add(`modal--width-${width}`)

    // Add the corresponding width class to the container
    if (width === 'full') {
      this.containerTarget.classList.add('w-full')
    } else {
      this.containerTarget.classList.add(`w-${width}`)
    }
  }

  updateHeightClass(height) {
    // Remove all modal height classes from the modal element
    this.modalElement.classList.remove(
      'modal--height-auto',
      'modal--height-sm',
      'modal--height-md',
      'modal--height-lg',
      'modal--height-xl',
      'modal--height-2xl',
      'modal--height-3xl',
      'modal--height-4xl',
      'modal--height-full',
      'modal--height-25',
      'modal--height-50',
      'modal--height-75',
      'modal--height-100',
    )

    // Add the new modal height class to the modal element
    // The CSS will handle applying the appropriate height to .modal__card
    this.modalElement.classList.add(`modal--height-${height}`)
  }
}
