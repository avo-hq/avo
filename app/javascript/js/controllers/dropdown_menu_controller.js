import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['menu']

  static values = {
    // One may want to have elements that are exempt from triggering the click outside event
    exemptionContainers: Array,
    logger: Boolean,
    // Opt-in: re-align a left-aligned panel to the right when it would overflow the
    // viewport, so it opens leftward instead of being clipped at the right edge.
    flip: Boolean,
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
    this.maybeFlip()
    this.element.addEventListener('keydown', this.boundHandleKeydown)
    document.body.classList.add('dropdown-open')
    this.dispatch('open', { bubbles: true })
    requestAnimationFrame(() => {
      const items = this.focusableItems
      if (items.length === 0) return

      const activeItem = items.find((el) =>
        [...el.classList].some((cls) => cls.endsWith('--active')) || el.getAttribute('aria-selected') === 'true',
      )
      ;(activeItem || items[0]).focus()
    })
  }

  close() {
    this.menuTarget.close()
    this.element.removeEventListener('keydown', this.boundHandleKeydown)
    document.body.classList.remove('dropdown-open')
  }

  // Re-align the panel when `flip` is enabled. We always re-measure from the
  // default left-aligned position (start-0), then switch to right-aligned (end-0)
  // only if the panel would spill past the right edge of the viewport — so it
  // opens leftward instead of being clipped. Dropdowns that don't opt in are
  // untouched. Assumes the opted-in panel is left-aligned by default.
  maybeFlip() {
    if (!this.flipValue || !this.hasMenuTarget) return

    this.menuTarget.classList.remove('start-auto', 'end-0')
    this.menuTarget.classList.add('start-0', 'end-auto')

    if (this.menuTarget.getBoundingClientRect().right > document.documentElement.clientWidth) {
      this.menuTarget.classList.remove('start-0', 'end-auto')
      this.menuTarget.classList.add('start-auto', 'end-0')
    }
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
