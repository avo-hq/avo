import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['selector']

  getFilterValue() {
    const filterValue = Array.from(this.selectorTarget.selectedOptions).map(({ value }) => value)

    return filterValue.length === 0 ? null : filterValue
  }

  getFilterClass() {
    const { filterClass } = this.selectorTarget.dataset

    return filterClass
  }
}
