import { Controller } from '@hotwired/stimulus'
import { destroy, put } from '@rails/request.js'
import debounce from 'lodash/debounce'

export default class extends Controller {
  static targets = ['sample', 'panel', 'outsideButton']

  static values = {
    visible: {
      type: Boolean,
      default: true,
    },
  }

  debouncedTextPropertyChange = debounce(this.textPropertyChange, 250)

  connect() {
    console.log('theme_controller')
    // console.log(this.elementTarget)
  }

  toggle(event) {
    console.log(event)
    const { params } = event
    const { property, value } = params
    console.log(property, value, params)
  }

  textPropertyChange(event) {
    console.log(event, event?.target?.value)

    this.updateVariables({ property: event.params.property, value: event.target.value })
  }

  async selectProperty({ params, target }) {
    const { property } = params
    const { value } = target
    console.log(property, value)

    this.updateVariables({ property, value })
  }

  togglePanel() {
    console.log('toggle-[anel')
    const translateClass = '-translate-x-[calc(100%+1rem)]'
    this.visibleValue = !this.visibleValue
    // if (this.panelTarget.dataset.contains('hidden')) {
    //   this.panelTarget.dataset.remove('hidden')
    //   // this.panelTarget.classList.remove('translate-x-full')
    //   // this.outsideButtonTarget.dataset.remove('')
    // } else {
    //   // this.panelTarget.classList.add('translate-x-full')
    //   this.outsideButtonTarget.dataset.add('hidden')
    // }
  }

  toggleColorsPanel() {
    this.panelTarget.hidden = !this.panelTarget.hidden
  }

  selectColor(event) {
    const { params } = event
    const { property, value } = params
    this.updateVariables({ property, value })
    this.sampleTarget.style.backgroundColor = value
  }

  resetVariable({ params }) {
    this.deleteVariable({ property: params.property })
    console.log('params->', params)
    this.sampleTarget.style.backgroundColor = params.initialValue
  }

  async updateVariables({ property, value }) {
    // TODO: dynamic route
    await put('/admin/theme', {
      responseKind: 'turbo-stream',
      body: {
        property,
        value,
      },
    })
  }

  async deleteVariable({ property }) {
    await destroy('/admin/theme', {
      responseKind: 'turbo-stream',
      body: {
        property,
      },
    })
  }
}
