import { Controller } from 'stimulus'
import SimpleMDE from 'simplemde'

export default class extends Controller {
  static targets = ['element']

  get view() {
    return this.elementTarget.dataset.view
  }

  connect() {
    const options = {
      element: this.elementTarget,
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
