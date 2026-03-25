import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['menu']

  static values = {
    // One may want to have elements that are exempt from triggering the click outside event
    exemptionContainers: Array,
    logger: Boolean,
  }

  get exemptionContainerTargets() {
    return this.exemptionContainersValue.map((selector) => document.querySelector(selector)).filter(Boolean)
  }

  get isOpen() {
    return this.menuTarget.hasAttribute('open')
  }

  get focusableItems() {
    return [...this.menuTarget.querySelectorAll('a, button')].filter(
      (el) => !el.closest('[hidden]') && el.dataset.disabled !== 'true',
    )
  }

  clickOutside(e) {
    if (this.hasMenuTarget) {
      const isInExemptionContainer = this.hasExemptionContainersValue && this.exemptionContainerTargets.some((container) => container.contains(e.target))

      if (!isInExemptionContainer && this.isOpen) {
        this.close()
      }
    }
  }

  connect() {
    useClickOutside(this)
    this.boundHandleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    this.element.removeEventListener('keydown', this.boundHandleKeydown)
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.show()
    this.element.addEventListener('keydown', this.boundHandleKeydown)
    requestAnimationFrame(() => {
      const items = this.focusableItems
      if (items.length > 0) items[0].focus()
    })
  }

  close() {
    this.menuTarget.close()
    this.element.removeEventListener('keydown', this.boundHandleKeydown)
  }

  handleKeydown(event) {
    const items = this.focusableItems
    if (items.length === 0) return

    const currentIndex = items.indexOf(document.activeElement)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        items[currentIndex < items.length - 1 ? currentIndex + 1 : 0].focus()
        break
      case 'ArrowUp':
        event.preventDefault()
        items[currentIndex > 0 ? currentIndex - 1 : items.length - 1].focus()
        break
      case 'Escape':
        event.preventDefault()
        this.close()
        break
      default:
    }
  }
}
