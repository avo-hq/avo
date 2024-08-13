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
    const options = {
      onClose: this.handleOnClose.bind(this),
    }

    this.pickerInstance = flatpickr(this.inputTarget, { ...options, ...this.pickerOptionsValue })
  }

  handleOnClose() {
    this.changeFilter()
  }
}
