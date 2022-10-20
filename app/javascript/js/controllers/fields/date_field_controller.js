import { Controller } from '@hotwired/stimulus'
import { DateTime } from 'luxon'
import flatpickr from 'flatpickr'

// Get the DateTime with the TZ offset applied.
function universalTimestamp(timestampStr) {
  return new Date(new Date(timestampStr).getTime() + (new Date(timestampStr).getTimezoneOffset() * 60 * 1000))
}

const RAW_DATE_FORMAT = 'y/LL/dd'
const RAW_TIME_FORMAT = 'TT'

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
    noCalendar: Boolean,
    relative: Boolean,
    fieldType: { type: String, default: 'dateTime' },
    pickerOptions: { type: Object, default: {} },
  }

  flatpickrInstance;

  cachedInitialValue;

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
    // Cache the initial value so we can fill it back on disconnection.
    // We do that so the JS parser will continue to work when the user hits the back button to return on this page.
    this.cacheInitialValue()

    if (this.isOnShow || this.isOnIndex) {
      this.initShow()
    } else if (this.isOnEdit) {
      this.initEdit()
    }
  }

  disconnect() {
    if (this.isOnShow || this.isOnIndex) {
      this.context.element.innerText = this.cachedInitialValue
    } else if (this.isOnEdit) {
      if (this.flatpickrInstance) this.flatpickrInstance.destroy()
    }
  }

  cacheInitialValue() {
    this.cachedInitialValue = this.initialValue
  }

  // Turns the value in the controller wrapper into the timezone of the browser
  initShow() {
    let value = this.parsedValue

    // Set the zone only if the type of field is date time or relative time.
    if (this.enableTimeValue && this.relativeValue) {
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
      noCalendar: false,
      ...this.pickerOptionsValue,
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

    // Hide calendar and only keep time picker.
    options.noCalendar = this.noCalendarValue

    if (this.initialValue) {
      // Enable timezone display
      if (this.enableTimeValue && this.relativeValue) {
        options.defaultDate = this.parsedValue.setZone(this.displayTimezone).toISO()

        options.dateFormat = 'Y-m-d H:i:S'
      } else {
        // Because the browser treats the date like a timestamp and updates it at 00:00 hour, when on a western timezone the date will be converted with one day offset.
        // Ex: 2022-01-30 will render as 2022-01-29 on an American timezone
        options.defaultDate = universalTimestamp(this.initialValue)
      }
    }

    this.flatpickrInstance = flatpickr(this.fakeInputTarget, options)

    // Don't try to parse the value if the input is empty.
    if (!this.initialValue) {
      return
    }

    let value
    switch (this.fieldTypeValue) {
      case 'time':
        // For time values, we should maintain the real value and format it to a time-friendly format.
        value = this.parsedValue.setZone(this.displayTimezone, { keepLocalTime: true }).toFormat(RAW_TIME_FORMAT)
        break
      case 'date':
        value = DateTime.fromJSDate(universalTimestamp(this.initialValue)).toFormat(RAW_DATE_FORMAT)
        break
      default:
      case 'dateTime':
        value = this.parsedValue.setZone(this.displayTimezone).toISO()
        break
    }

    this.updateRealInput(value)
  }

  onChange(selectedDates) {
    // No date has been selected
    if (selectedDates.length === 0) {
      this.updateRealInput('')

      return
    }

    let args = {}

    // For values that involve time we should keep the local time.
    if (this.timezoneValue || !this.relativeValue) {
      args = { keepLocalTime: true }
    } else {
      args = { keepLocalTime: false }
    }

    let value
    switch (this.fieldTypeValue) {
      case 'time':
        // For time values, we should maintain the real value and format it to a time-friendly format.
        value = DateTime.fromISO(selectedDates[0].toISOString()).setZone('UTC', args).toFormat(RAW_TIME_FORMAT)
        break
      case 'date':
        value = DateTime.fromISO(selectedDates[0].toISOString()).setZone('UTC', { keepLocalTime: true }).toFormat(RAW_DATE_FORMAT)
        break
      default:
      case 'dateTime':
        value = DateTime.fromISO(selectedDates[0].toISOString()).setZone('UTC', args).toISO()
        break
    }

    this.updateRealInput(value)
  }

  // Value should be a string
  updateRealInput(value) {
    this.inputTarget.value = value
  }
}
