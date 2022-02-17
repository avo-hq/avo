import { Controller } from 'stimulus'
import { DateTime } from 'luxon'
import flatpickr from 'flatpickr'

import { castBoolean } from '../../helpers/cast_boolean'

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
      currentValue = universalTimestamp(this.inputTarget.value)
    }

    options.defaultDate = currentValue

    flatpickr(this.inputTarget, options)
  }
}
