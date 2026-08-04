import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="modal-size"
export default class extends Controller {
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
    this.#swapModifier('modal--width-', width)
  }

  updateHeightClass(height) {
    this.#swapModifier('modal--height-', height)
  }

  // The CSS owns the sizes: each `modal--width-*` / `modal--height-*` modifier
  // sizes `.modal__card`. Swapping by prefix means a new size token is a CSS
  // rule and nothing else — no list here to keep in sync with the stylesheet.
  #swapModifier(prefix, value) {
    this.modalElement.classList.remove(...[...this.modalElement.classList].filter((name) => name.startsWith(prefix)))
    this.modalElement.classList.add(`${prefix}${value}`)
  }
}
