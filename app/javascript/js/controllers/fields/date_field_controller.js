import { Controller } from '@hotwired/stimulus'
import { DateTime } from 'luxon'
import flatpickr from 'flatpickr'

import { castBoolean } from '../../helpers/cast_boolean'

// Get the DateTime with the TZ offset applied.
function universalTimestamp(timestampStr) {
  return new Date(new Date(timestampStr).getTime() + (new Date(timestampStr).getTimezoneOffset() * 60 * 1000))
}

export default class extends Controller {
  static targets = ['input']

  connect() {
    const options = {
      enableTime: false,
      enableSeconds: false,
      // eslint-disable-next-line camelcase
      time_24hr: false,
      locale: {
        firstDayOfWeek: 0,
      },
      altInput: true,
    }
    const enableTime = castBoolean(this.inputTarget.dataset.enableTime)

    // Set the format of the displayed input field.
    options.altFormat = this.inputTarget.dataset.pickerFormat

    // Disable native input in mobile browsers
    options.disableMobile = this.inputTarget.dataset.disableMobile

    // Set first day of the week.
    options.locale.firstDayOfWeek = this.inputTarget.dataset.firstDayOfWeek

    // Enable time if needed.
    options.enableTime = enableTime
    options.enableSeconds = enableTime

    let currentValue

    // enable timezone display
    if (enableTime) {
      currentValue = DateTime.fromISO(this.inputTarget.value, { zone: window.Avo.configuration.timezone })
      currentValue = currentValue.setZone(this.inputTarget.dataset.timezone)
      currentValue = currentValue.toISO()

      options.dateFormat = 'Y-m-d H:i:S'
      // eslint-disable-next-line camelcase
      options.time_24hr = castBoolean(this.inputTarget.dataset.time24hr)
      // this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
      options.appTimezone = this.inputTarget.dataset.timezone
    } else {
      // Because the browser treats the date like a timestamp and updates it ot 00:00 hour, when on a western timezone the date will be converted with one day offset.
      // Ex: 2022-01-30 will render as 2022-01-29 on an American timezone
      currentValue = universalTimestamp(this.inputTarget.value)
    }

    options.defaultDate = currentValue

    flatpickr(this.inputTarget, options)
  }
}
