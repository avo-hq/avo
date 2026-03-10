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

  get isDark() {
    return document.documentElement.classList.contains('dark')
  }

  get resolvedTheme() {
    return this.isDark ? 'material-darker' : 'default'
  }

  connect() {
    const options = {
      element: this.elementTarget,
      spellChecker: this.componentOptions.spell_checker,
      autoRefresh: { delay: 500 },
      theme: this.resolvedTheme,
    }

    if (this.view === 'show') {
      options.toolbar = false
      options.status = false
    }

    this.easyMde = new EasyMDE(options)
    if (this.view === 'show') {
      this.easyMde.codemirror.options.readOnly = true
    }

    this.easyMde.codemirror.on('keydown', (_cm, event) => {
      if (event.key === 'Escape') {
        this.easyMde.codemirror.getInputField().blur()
      }
    })

    const vm = this
    this.observer = new MutationObserver(() => {
      vm.easyMde.codemirror.setOption('theme', vm.resolvedTheme)
    })
    this.observer.observe(document.documentElement, { attributes: true, attributeFilter: ['class'] })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    if (this.easyMde) {
      this.easyMde.toTextArea()
      this.easyMde = null
    }
  }
}
