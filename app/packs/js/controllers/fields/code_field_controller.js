import 'codemirror/mode/css/css'

import 'codemirror/mode/dockerfile/dockerfile'
import 'codemirror/mode/htmlmixed/htmlmixed'
import 'codemirror/mode/javascript/javascript'
import 'codemirror/mode/markdown/markdown'
import 'codemirror/mode/nginx/nginx'
import 'codemirror/mode/php/php'
import 'codemirror/mode/ruby/ruby'
import 'codemirror/mode/sass/sass'
import 'codemirror/mode/shell/shell'
import 'codemirror/mode/sql/sql'
import 'codemirror/mode/vue/vue'
import 'codemirror/mode/xml/xml'

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

    setTimeout(() => {
      CodeMirror.fromTextArea(this.elementTarget, options)
    }, 1)
  }
}
