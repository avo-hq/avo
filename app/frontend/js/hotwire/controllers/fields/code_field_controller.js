import { Controller } from 'stimulus'
import CodeMirror from 'codemirror'

export default class extends Controller {
  static targets = ['element']

  connect() {
    const options = {
      readOnly: Boolean(parseInt(this.elementTarget.dataset.readOnly, 10)),
      mode: this.elementTarget.dataset.language,
      theme: this.elementTarget.dataset.theme,
      tabSize: this.elementTarget.dataset.tabSize,
      indentWithTabs: Boolean(parseInt(this.elementTarget.dataset.indentWithTabs, 10)),
      lineWrapping: Boolean(parseInt(this.elementTarget.dataset.lineWrapping, 10)),
      lineNumbers: true,
    }

    CodeMirror.fromTextArea(this.elementTarget, options)
  }
}
