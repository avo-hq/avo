import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'

export default class extends Controller {
  static targets = ['source', 'content']

  connect() {
    tippy(this.sourceTarget, {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      theme: 'light',
    })
  }
}
