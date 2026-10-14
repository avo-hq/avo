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
    const { locale, ...options } = this.pickerOptionsValue

    this.pickerInstance = flatpickr(this.inputTarget, {
      ...options,
      locale: { ...flatpickrLocale(), ...locale },
    })
  }

  clear() {
    this.inputTarget._flatpickr.clear()
  }
}
