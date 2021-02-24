import { Controller } from 'stimulus'
import { castBoolean } from '@/js/helpers/cast_boolean'
import CodeMirror from 'codemirror'

export default class extends Controller {
  static targets = ['element']

  connect() {
    const options = {
      readOnly: castBoolean(this.elementTarget.dataset.readOnly),
      mode: this.elementTarget.dataset.language,
      theme: this.elementTarget.dataset.theme,
      tabSize: this.elementTarget.dataset.tabSize,
      indentWithTabs: castBoolean(this.elementTarget.dataset.indentWithTabs),
      lineWrapping: castBoolean(this.elementTarget.dataset.lineWrapping),
      lineNumbers: true,
    }

    CodeMirror.fromTextArea(this.elementTarget, options)
  }
}
