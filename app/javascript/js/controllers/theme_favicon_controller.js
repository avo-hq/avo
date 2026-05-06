import { Controller } from '@hotwired/stimulus'

// Lives on `<link rel="icon">`; syncs href with `.dark` on `document.documentElement`.
export default class extends Controller {
  static values = {
    lightUrl: String,
    darkUrl: String,
  }

  connect() {
    if (!this.lightUrlValue || !this.darkUrlValue) return

    const root = document.documentElement
    this.observer = new MutationObserver(() => this.sync())
    this.observer.observe(root, { attributes: true, attributeFilter: ['class'] })

    this.sync()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  sync() {
    const link = this.element
    const next = document.documentElement.classList.contains('dark') ? this.darkUrlValue : this.lightUrlValue
    if (!next || link.getAttribute('href') === next) return

    link.setAttribute('href', next)
  }
}
