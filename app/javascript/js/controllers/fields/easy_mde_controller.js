import { Controller } from '@hotwired/stimulus'
import EasyMDE from 'easymde'

export default class extends Controller {
  static targets = ['element']

  get view() {
    return this.elementTarget.dataset.view
  }

  get componentOptions() {
    try {
      return JSON.parse(this.elementTarget.dataset.componentOptions)
    } catch (error) {
      return {}
    }
  }

  connect() {
    const options = {
      element: this.elementTarget,
      spellChecker: this.componentOptions.spell_checker,
      autoRefresh: { delay: 500},
    }

    if (this.view === 'show') {
      options.toolbar = false
      options.status = false
    }

    this.easyMde = new EasyMDE(options)
    if (this.view === 'show') {
      this.easyMde.codemirror.options.readOnly = true
    }
  }

  disconnect() {
    if (this.easyMde) {
      this.easyMde.toTextArea()
      this.easyMde = null
    }
  }
}
