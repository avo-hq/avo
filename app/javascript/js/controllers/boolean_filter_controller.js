import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['option']

  getFilterValue() {
    const filterValue = {}

    this.optionTargets.forEach((option) => {
      filterValue[option.value] = option.checked
    })

    return filterValue
  }

  getFilterClass() {
    const { filterClass } = this.optionTarget.dataset

    return filterClass
  }
}
