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
    }

    if (this.view === 'show') {
      options.toolbar = false
      options.status = false
    }

    const easyMde = new EasyMDE(options)
    if (this.view === 'show') {
      easyMde.codemirror.options.readOnly = true
    }
  }
}
