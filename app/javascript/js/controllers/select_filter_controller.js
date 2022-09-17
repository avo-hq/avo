import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['selector']

  getFilterValue() {
    return this.selectorTarget.value === '' ? null : this.selectorTarget.value
  }

  getFilterClass() {
    const { filterClass } = this.selectorTarget.dataset

    return filterClass
  }
}
