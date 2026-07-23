import { Controller } from '@hotwired/stimulus'

// Reveals a "Back to top" pill when the user scrolls back up, mirroring the
// Furo docs theme (used by diataxis.fr): hidden within `threshold` px of the
// top, shown on upward scroll, hidden again on downward scroll.
export default class extends Controller {
  static values = { threshold: { type: Number, default: 64 } }

  connect() {
    this.lastScroll = this.scrollTop
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener('scroll', this.onScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener('scroll', this.onScroll)
  }

  get scrollTop() {
    return window.pageYOffset || document.documentElement.scrollTop
  }

  onScroll() {
    const current = this.scrollTop

    if (current < this.thresholdValue) {
      this.hide()
    } else if (current < this.lastScroll) {
      this.show() // scrolling up
    } else if (current > this.lastScroll) {
      this.hide() // scrolling down
    }

    this.lastScroll = current
  }

  scrollToTop(event) {
    event.preventDefault()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  show() {
    this.element.classList.add('back-to-top--visible')
  }

  hide() {
    this.element.classList.remove('back-to-top--visible')
  }
}
