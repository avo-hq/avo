import { Controller } from '@hotwired/stimulus'
import { useClickOutside } from 'stimulus-use'

export default class extends Controller {
  static targets = ['menu']

  static values = {
    // One may want to have elements that are exempt from triggering the click outside event
    exemptionContainers: Array,
    logger: Boolean,
    // Opt-in: open the panel start-aligned when it fits, end-aligned when it
    // would run past the viewport's end edge, so it is never clipped.
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

  // Re-align the panel when `flip` is enabled. Measure from the start-aligned
  // position first, then switch to end-aligned only if the panel would spill
  // past the viewport edge on the end side (right in LTR, left in RTL), so it
  // opens toward the free space instead of being clipped. The two modifiers are
  // defined in components/ui/dropdown.css. Dropdowns that don't opt in are
  // untouched.
  maybeFlip() {
    if (!this.flipValue || !this.hasMenuTarget) return

    const panel = this.menuTarget
    panel.classList.remove('dropdown-popover--end')
    panel.classList.add('dropdown-popover--start')

    const rect = panel.getBoundingClientRect()
    const rtl = getComputedStyle(panel).direction === 'rtl'
    const overflows = rtl ? rect.left < 0 : rect.right > document.documentElement.clientWidth
    if (overflows) {
      panel.classList.remove('dropdown-popover--start')
      panel.classList.add('dropdown-popover--end')
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
