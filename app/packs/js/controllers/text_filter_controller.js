import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['text']

  getFilterValue() {
    return this.textTarget.value
  }

  tryToSubmit(e) {
    if (e.keyCode === 13) {
      return this.changeFilter()
    }

    return undefined
  }

  getFilterClass() {
    const { filterClass } = this.textTarget.dataset

    return filterClass
  }
}
