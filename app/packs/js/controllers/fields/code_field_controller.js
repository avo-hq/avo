import { Controller } from 'stimulus'
import { castBoolean } from '@/js/helpers/cast_boolean'
import CodeMirror from 'codemirror'
import 'codemirror/mode/css/css.js'
import 'codemirror/mode/css/css.js'
import 'codemirror/mode/dockerfile/dockerfile.js'
import 'codemirror/mode/htmlmixed/htmlmixed.js'
import 'codemirror/mode/javascript/javascript.js'
import 'codemirror/mode/markdown/markdown.js'
import 'codemirror/mode/nginx/nginx.js'
import 'codemirror/mode/php/php.js'
import 'codemirror/mode/ruby/ruby.js'
import 'codemirror/mode/sass/sass.js'
import 'codemirror/mode/shell/shell.js'
import 'codemirror/mode/sql/sql.js'
import 'codemirror/mode/vue/vue.js'
import 'codemirror/mode/xml/xml.js'

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
