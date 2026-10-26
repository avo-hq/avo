import { Controller } from '@hotwired/stimulus'

// Reveals a "Back to top" pill once the page is scrolled `threshold` px down,
// in either direction, and hides it again near the top.
export default class extends Controller {
  static values = { threshold: { type: Number, default: 400 } }

  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener('scroll', this.onScroll, { passive: true })
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener('scroll', this.onScroll)
  }

  get scrollTop() {
    return window.pageYOffset || document.documentElement.scrollTop
  }

  onScroll() {
    if (this.scrollTop >= this.thresholdValue) {
      this.show()
    } else {
      this.hide()
    }
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
