import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['text']

  getFilterValue() {
    return this.textTarget.value
  }

  getFilterClass() {
    const { filterClass } = this.textTarget.dataset

    return filterClass
  }
}
