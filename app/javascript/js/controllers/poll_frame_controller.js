import { Controller } from '@hotwired/stimulus'

// Reloads the surrounding Turbo Frame every few seconds. The server stops the polling by rendering the frame
// without this controller.
export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 2000 } }

  connect() {
    this.timer = setTimeout(() => {
      // A fresh query string every time: Turbo skips a frame whose src didn't change.
      this.element.closest('turbo-frame').src = `${this.urlValue}?at=${Date.now()}`
    }, this.intervalValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
