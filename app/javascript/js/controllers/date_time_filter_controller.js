import flatpickr from 'flatpickr'

import BaseFilterController from './filter_controller'

export default class extends BaseFilterController {
  static targets = ['input', 'calendar', 'calendarContainer']

  static values = {
    class: String,
    pickerOptions: Object,
  }

  getFilterValue() {
    return this.inputTarget.value || null
  }

  getFilterClass() {
    return this.classValue
  }

  connect() {
    this.initFlatpickr()
  }

  initFlatpickr() {
    const options = this.pickerOptionsValue
    const isRange = options.mode === 'range'

    this.pickerInstance = flatpickr(this.calendarTarget, {
      ...options,
      inline: true,
      onChange: (selectedDates, dateStr) => {
        if (!selectedDates.length || !dateStr) return

        const done = !isRange || selectedDates.length === 2

        this.inputTarget.value = dateStr

        if (done) {
          this.calendarContainerTarget.hidePopover()
        }
      },
    })

    // Pre-populate the display input from the default/pre-selected date
    if (options.defaultDate) {
      const defaultDate = options.defaultDate
      if (Array.isArray(defaultDate)) {
        this.inputTarget.value = defaultDate.join(' to ')
      } else {
        this.inputTarget.value = String(defaultDate)
      }
    }
  }

  openCalendar() {
    this.calendarContainerTarget.showPopover()
  }

  clear() {
    this.pickerInstance.clear()
    this.inputTarget.value = ''
  }
}
