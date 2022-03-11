import { Controller } from '@hotwired/stimulus'
import SimpleMDE from 'simplemde'

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

    const simpleMde = new SimpleMDE(options)
    if (this.view === 'show') {
      simpleMde.codemirror.options.readOnly = true
    }
  }
}
