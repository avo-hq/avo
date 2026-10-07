import { Info } from 'luxon'

// Flatpickr lists the weekdays from Sunday, Luxon from Monday.
const sundayFirst = (weekdays) => [weekdays[6], ...weekdays.slice(0, 6)]

// Month and weekday names for flatpickr in the locale of the <html lang> attribute.
// Luxon reads them from the browser's native Intl API, so no flatpickr locale files are bundled.
export default function flatpickrLocale() {
  const locale = document.documentElement.lang || 'en'

  return {
    weekdays: {
      shorthand: sundayFirst(Info.weekdays('short', { locale })),
      longhand: sundayFirst(Info.weekdays('long', { locale })),
    },
    months: {
      shorthand: Info.months('short', { locale }),
      longhand: Info.months('long', { locale }),
    },
  }
}
