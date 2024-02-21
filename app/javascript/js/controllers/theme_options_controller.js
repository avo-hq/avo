import { Controller } from '@hotwired/stimulus'
// import { put } from '@rails/request.js'
import { put } from '@rails/request.js'
import kebabCase from 'lodash/kebabCase'

export default class extends Controller {
  static targets = ['label']

  static values = {
    path: String,
  }

  cssVariables = ['borderRadiusPanel', 'colorNeutral', 'colorPrimary', 'strokeWidth', 'density']

  borderRadius = 1.25

  strokeWidth = 1

  colorPrimary = '#0586DD'

  colorNeutral = '#333'

  density = 0

  // Value in rgb
  // Returns the final color value
  colorPrimaryValue() {
    let result = '';

    // TODO: compute the colors dynamically
    [50, 100, 150, 200, 300, 400, 500, 600, 700, 800, 850, 900].forEach((key) => {
      result += this.#outputLine(`colorPrimary${key}`, this.colorPrimary)
    })

    return result
  }

  // Value in rgb
  // Returns the final color value
  colorNeutralValue() {
    return this.#outputLine('colorNeutral', this.colorNeutral)
  }

  // Returns value in rem
  borderRadiusPanelValue() {
    const value = this.borderRadius * 1

    // return `${value}rem`
    return this.#outputLine('borderRadiusPanel', `${value}rem`)
  }

  // Returns value in rem
  strokeWidthValue() {
    const value = this.strokeWidth * 1

    // return `${value}rem`
    return this.#outputLine('strokeWidth', `${value}rem`)
  }

  // Returns value in rem
  densityValue() {
    const result = []

    // const scale = {
    //   '-3': 0,
    //   '-2': 0.25,
    //   '-1': 0.5,
    //   0: 0.75,
    //   1: 1,
    //   2: 1.25,
    //   3: 1.5,
    // }
    const paddingXScale = {
      '-4': 0,
      '-3': 0.5,
      '-2': 1,
      '-1': 1.25,
      0: 1.5,
      1: 1.75,
      2: 2,
      // 3: 1.75,
      // 4: 2,
    }
    const paddingYScale = {
      '-4': 0,
      '-3': 0.25,
      '-2': 0.5,
      '-1': 0.75,
      0: 1,
      1: 1.25,
      2: 1.5,
      // 3: 1.75,
      // 4: 2,
    }
    const value = paddingYScale[this.density]
    console.log(this.density, value)

    result.push(this.#outputLine('padding-index-field-wrapper', `${value}rem`))
    result.push(this.#outputLine('padding-field-wrapper-y', `${value}rem`))
    result.push(this.#outputLine('padding-field-wrapper-x', `${paddingXScale[this.density]}rem`))

    return result.join('\n')
  }

  get template() {
    const vm = this
    const contents = this.cssVariables.map((method) => vm[`${method}Value`]()).join('\n')

    return `:root {
${contents}
    }`
  }

  updateProperty(e) {
    const { params } = e
    const { property } = params
    this[property] = e.target.value
    this.updateDOM()
  }

  updateDOM() {
    console.log(this.template)
    document.querySelector('[data-theme-options-target="cssVariablesRoot"]').innerHTML = this.template
  }

  async save() {
    console.log('save')

    const response = await put(this.pathValue, {
      body: {
        foo: 'bar',
      },
    })
    const data = await response.json()
    console.log(data)
  }

  #outputLine(property, value) {
    return `--${kebabCase(property)}: ${value};`
  }
}
