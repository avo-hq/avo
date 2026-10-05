import flatpickr from 'flatpickr'

import BaseFilterController from './filter_controller'
import flatpickrLocale from '../helpers/flatpickr_locale'

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
    this.pickerInstance = flatpickr(this.inputTarget, { locale: flatpickrLocale(), ...this.pickerOptionsValue })
  }

  clear() {
    this.inputTarget._flatpickr.clear()
  }
}
