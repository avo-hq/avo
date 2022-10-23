import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['startDate', 'endDate']

  static values = { class: String }

  getFilterValue() {
    return {
      start: this.startDateTarget.value,
      end: this.endDateTarget.value,
    }
  }

  getFilterClass() {
    return this.classValue
  }
}
