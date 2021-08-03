import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['selector']

  getFilterValue() {
    return Array.from(this.selectorTarget.selectedOptions).map(({ value }) => value)
  }

  getFilterClass() {
    const { filterClass } = this.selectorTarget.dataset

    return filterClass
  }
}
