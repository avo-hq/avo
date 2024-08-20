import flatpickr from 'flatpickr'

import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['input']

  static values = {
    class: String,
    pickerOptions: Object,
  }

  getFilterValue() {
    return this.inputTarget.value
  }

  getFilterClass() {
    return this.classValue
  }

  connect() {
    this.initFlatpickr()
  }

  initFlatpickr() {
    this.pickerInstance = flatpickr(this.inputTarget, this.pickerOptionsValue)
  }

  clear() {
    this.inputTarget._flatpickr.clear()
  }
}
