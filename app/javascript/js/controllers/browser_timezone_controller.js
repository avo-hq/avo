import Cookies from 'js-cookie'
import { Controller } from '@hotwired/stimulus'

// Mirrors the browser's IANA time zone into a cookie so the server can render
// dates and times in the viewer's local zone (see BaseApplicationController#set_browser_timezone).
// Attached to <body> only when `config.use_browser_timezone` is on.
//
// The zone only exists inside the browser's JS runtime — no HTTP header carries
// it — so the first-ever request renders in the server zone. When the cookie is
// missing or stale, we set it and soft-reload once through Turbo. The one-shot
// `timezone_changed` cookie tells the server to announce the change with a flash.
export default class extends Controller {
  connect() {
    const zone = Intl.DateTimeFormat().resolvedOptions().timeZone

    if (!zone || Cookies.get(this.cookieKey) === zone) return

    Cookies.set(this.cookieKey, zone, { expires: 365, sameSite: 'Lax' })

    // Read-back proves the cookie stuck. With cookies blocked the write is a
    // no-op, and reloading would loop forever — so we stay on the server zone.
    if (Cookies.get(this.cookieKey) !== zone) return

    Cookies.set(this.changedCookieKey, '1', { sameSite: 'Lax' })
    window.Turbo.visit(window.location.href, { action: 'replace' })
  }

  get cookieKey() {
    return `${window.Avo.configuration.cookies_key}.browser_timezone`
  }

  get changedCookieKey() {
    return `${window.Avo.configuration.cookies_key}.timezone_changed`
  }
}
