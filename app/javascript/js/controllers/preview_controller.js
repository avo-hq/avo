import { Controller } from '@hotwired/stimulus'
import tippy from 'tippy.js'

export default class extends Controller {
  static values = {
    url: String,
  }

  connect() {
    const vm = this;

    tippy(vm.context.element, {
      content: "loading...",
      allowHTML: true,
      theme: 'light',
      maxWidth: 550,
      async onShow(instance) {
        const response = await fetch(vm.urlValue)
        const content = await response.text()
        instance.setContent(content)
      },
    })
  }
}
