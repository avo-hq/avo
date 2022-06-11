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
import 'codemirror/mode/yaml/yaml'

import { Controller } from '@hotwired/stimulus'
import CodeMirror from 'codemirror'

import { castBoolean } from '../../helpers/cast_boolean'

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

    const vm = this

    setTimeout(() => {
      CodeMirror.fromTextArea(this.elementTarget, options).on('change', (cm) => {
        // Add this innerText change and dispatch an event to allow stimulus to pick up the input event.
        vm.elementTarget.innerText = cm.getValue()
        vm.elementTarget.dispatchEvent(new Event('input'))
      })
    }, 1)
  }
}
