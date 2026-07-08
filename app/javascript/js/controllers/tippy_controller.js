import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'

import nearestTopLayer from '../helpers/top_layer'

export default class extends Controller {
  static targets = ['source', 'content']

  connect() {
    this.tippyInstance = tippy(this.sourceTarget, {
      content: this.contentTarget.innerHTML,
      allowHTML: true,
      theme: 'basic',
      // Default is <body>; append into a top-layer modal when the trigger is
      // inside one, otherwise it paints underneath (see helpers/top_layer).
      appendTo: (reference) => nearestTopLayer(reference) ?? document.body,
    })
  }

  disconnect() {
    if (this.tippyInstance) {
      this.tippyInstance.destroy()
      this.tippyInstance = null
    }
  }
}
