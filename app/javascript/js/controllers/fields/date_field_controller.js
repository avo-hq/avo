import { Controller } from '@hotwired/stimulus'
import { DateTime } from 'luxon'
import flatpickr from 'flatpickr'

// Get the DateTime with the TZ offset applied.
function universalTimestamp(timestampStr) {
  return new Date(new Date(timestampStr).getTime() + (new Date(timestampStr).getTimezoneOffset() * 60 * 1000))
}

export default class extends Controller {
  static targets = ['input', 'fakeInput']

  static values = {
    view: String,
    timezone: String,
    format: String,
    enableTime: Boolean,
    pickerFormat: String,
    firstDayOfWeek: Number,
    time24Hr: Boolean,
    disableMobile: Boolean,
  }

  get browserZone() {
    const time = DateTime.local()

    return time.zoneName
  }

  get initialValue() {
    if (this.isOnShow || this.isOnIndex) {
      return this.context.element.innerText
    } if (this.isOnEdit) {
      return this.inputTarget.value
    }

    return null
  }

  get isOnIndex() {
    return this.viewValue === 'index'
  }

  get isOnEdit() {
    return this.viewValue === 'edit'
  }

  get isOnShow() {
    return this.viewValue === 'show'
  }

  // Parse the time as if it were UTC
  get parsedValue() {
    return DateTime.fromISO(this.initialValue, { zone: 'UTC' })
  }

  get displayTimezone() {
    return this.timezoneValue || this.browserZone
  }

  connect() {
    if (this.isOnShow || this.isOnIndex) {
      this.initShow()
    } else if (this.isOnEdit) {
      this.initEdit()
    }
  }

  // Turns the value in the controller wrapper into the timezone of the browser
  initShow() {
    let value = this.parsedValue

    // Set the zone only if the type of field is date time.
    if (this.enableTimeValue) {
      value = value.setZone(this.displayTimezone)
    }

    this.context.element.innerText = value.toFormat(this.formatValue)
  }

  initEdit() {
    const options = {
      enableTime: false,
      enableSeconds: false,
      // eslint-disable-next-line camelcase
      time_24hr: this.time24HrValue,
      locale: {
        firstDayOfWeek: 0,
      },
      altInput: true,
      onChange: this.onChange.bind(this),
    }

    // Set the format of the displayed input field.
    options.altFormat = this.pickerFormatValue

    // Disable native input in mobile browsers
    options.disableMobile = this.disableMobileValue

    // Set first day of the week.
    options.locale.firstDayOfWeek = this.firstDayOfWeekValue

    // Enable time if needed.
    options.enableTime = this.enableTimeValue
    options.enableSeconds = this.enableTimeValue

    // enable timezone display
    if (this.enableTimeValue) {
      options.defaultDate = this.parsedValue.setZone(this.displayTimezone).toISO()

      options.dateFormat = 'Y-m-d H:i:S'
    } else {
      // Because the browser treats the date like a timestamp and updates it at 00:00 hour, when on a western timezone the date will be converted with one day offset.
      // Ex: 2022-01-30 will render as 2022-01-29 on an American timezone
      options.defaultDate = universalTimestamp(this.initialValue)
    }

    flatpickr(this.fakeInputTarget, options)

    if (this.enableTimeValue) {
      this.updateRealInput(this.parsedValue.setZone(this.displayTimezone).toISO())
    } else {
      this.updateRealInput(universalTimestamp(this.initialValue))
    }
  }

  onChange(selectedDates) {
    // No date has been selected
    if (selectedDates.length === 0) {
      this.updateRealInput('')

      return
    }

    let time
    let args = {}

    if (this.timezoneValue) {
      args = { keepLocalTime: true }
    } else {
      args = { keepLocalTime: false }
    }

    if (this.enableTimeValue) {
      time = DateTime.fromISO(selectedDates[0].toISOString()).setZone('UTC', args)
    } else {
      time = DateTime.fromISO(selectedDates[0].toISOString()).setZone('UTC', { keepLocalTime: true })
    }

    this.updateRealInput(time)
  }

  updateRealInput(value) {
    this.inputTarget.value = value
  }
}
