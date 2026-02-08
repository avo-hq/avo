import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'

export default class extends Controller {
  static targets = ['source', 'content']

  connect() {
    this.tippyInstance = tippy(this.sourceTarget, {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      theme: 'light',
    })
  }

  disconnect() {
    if (this.tippyInstance) {
      this.tippyInstance.destroy()
      this.tippyInstance = null
    }
  }
}
