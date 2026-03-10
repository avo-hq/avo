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

  get isDark() {
    return document.documentElement.classList.contains('dark')
  }

  get resolvedTheme() {
    return this.isDark ? 'material-darker' : (this.elementTarget.dataset.theme || 'default')
  }

  connect() {
    const options = {
      readOnly: castBoolean(this.elementTarget.dataset.readOnly),
      mode: this.elementTarget.dataset.language,
      theme: this.resolvedTheme,
      tabSize: this.elementTarget.dataset.tabSize,
      indentWithTabs: castBoolean(this.elementTarget.dataset.indentWithTabs),
      lineWrapping: castBoolean(this.elementTarget.dataset.lineWrapping),
      lineNumbers: true,
      extraKeys: {
        Esc: (cm) => cm.getInputField().blur(),
      },
    }

    const vm = this

    setTimeout(() => {
      vm.cm = CodeMirror.fromTextArea(vm.elementTarget, options)
      vm.cm.on('change', (cm) => {
        vm.elementTarget.innerText = cm.getValue()
        vm.elementTarget.dispatchEvent(new Event('input'))
      })
    }, 1)

    this.observer = new MutationObserver(() => {
      if (vm.cm) vm.cm.setOption('theme', vm.resolvedTheme)
    })
    this.observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    this.element.querySelector('.CodeMirror').CodeMirror.toTextArea()
  }
}
