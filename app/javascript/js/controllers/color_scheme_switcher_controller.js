import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button']

  static values = {
    currentScheme: String,
    currentTheme: String,
  }

  connect() {
    // Prioritize cookie values over server-side values (cookie is source of truth)
    const cookieScheme = Cookies.get('color_scheme')
    const cookieTheme = Cookies.get('theme')

    // Use cookie value if it exists, otherwise fall back to server value or default
    this.currentSchemeValue = cookieScheme || this.currentSchemeValue || 'auto'
    this.currentThemeValue = cookieTheme || this.currentThemeValue || 'brand'

    this.applyScheme()
    this.applyTheme()

    // Watch for live changes when the user has "auto" as the default setting
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    this.mediaQueryListener = () => {
      if (this.currentSchemeValue === 'auto') {
        this.applyScheme()
      }
    }
    this.mediaQuery.addEventListener('change', this.mediaQueryListener)
  }

  disconnect() {
    if (this.mediaQuery && this.mediaQueryListener) {
      this.mediaQuery.removeEventListener('change', this.mediaQueryListener)
    }
  }

  setScheme(event) {
    event.preventDefault()
    const { scheme } = event.currentTarget.dataset

    if (!scheme || !['auto', 'light', 'dark'].includes(scheme)) return

    this.currentSchemeValue = scheme
    this.saveScheme()
    this.applyScheme()
  }

  setTheme(event) {
    event.preventDefault()
    const { theme } = event.currentTarget.dataset

    if (!theme || !['brand', 'slate', 'stone'].includes(theme)) return

    this.currentThemeValue = theme
    this.saveTheme()
    this.applyTheme()
  }

  saveScheme() {
    if (this.currentSchemeValue === 'auto') {
      Cookies.remove('color_scheme')
    } else {
      Cookies.set('color_scheme', this.currentSchemeValue)
    }

    // Persist to server via AJAX
    this.persistToServer('color_scheme', this.currentSchemeValue === 'auto' ? null : this.currentSchemeValue)
  }

  saveTheme() {
    if (this.currentThemeValue === 'brand') {
      Cookies.remove('theme')
    } else {
      Cookies.set('theme', this.currentThemeValue)
    }

    // Persist to server via AJAX
    this.persistToServer('theme', this.currentThemeValue === 'brand' ? null : this.currentThemeValue)
  }

  persistToServer(type, value) {
    const formData = new FormData()
    if (type === 'color_scheme') {
      formData.append('color_scheme', value || 'auto')
    } else if (type === 'theme') {
      formData.append('theme', value || 'brand')
    }

    // Get the current values to preserve the other setting
    const currentScheme = Cookies.get('color_scheme') || 'auto'
    const currentTheme = Cookies.get('theme') || 'brand'

    if (type === 'color_scheme') {
      formData.append('theme', currentTheme === 'brand' ? '' : currentTheme)
    } else {
      formData.append('color_scheme', currentScheme === 'auto' ? '' : currentScheme)
    }

    const path = this.element.dataset.path || '/avo/color_scheme'
    fetch(path, {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
        Accept: 'text/vnd.turbo-stream.html',
      },
    }).catch(() => {
      // Silently fail - cookies are already set
    })
  }

  applyScheme() {
    const scheme = this.currentSchemeValue || 'auto'

    // Remove all scheme selection classes
    document.documentElement.classList.remove('scheme-light', 'scheme-dark', 'scheme-auto')

    if (scheme === 'light') {
      document.documentElement.classList.add('scheme-light')
      document.documentElement.classList.remove('dark')
    } else if (scheme === 'dark') {
      document.documentElement.classList.add('scheme-dark')
      document.documentElement.classList.add('dark')
    } else if (scheme === 'auto') {
      document.documentElement.classList.add('scheme-auto')
      // Set dark class based on system preference
      const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      if (isDark) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    }
  }

  applyTheme() {
    // Remove all theme classes
    document.documentElement.classList.remove('theme-slate', 'theme-stone')

    // Add the selected theme class (brand means no theme class)
    const theme = this.currentThemeValue || 'brand'
    if (theme !== 'brand') {
      document.documentElement.classList.add(`theme-${theme}`)
    }
  }
}
