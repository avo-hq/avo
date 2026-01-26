import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentPanel']

  connect() {
    // Read from cookies (cookie is source of truth)
    const cookieScheme = Cookies.get('color_scheme')
    const cookieTheme = Cookies.get('theme')
    const cookieAccent = Cookies.get('accent_color')

    // Use cookie value if it exists, otherwise use default
    this.currentSchemeValue = cookieScheme || 'auto'
    this.currentThemeValue = cookieTheme || 'brand'
    this.currentAccentValue = cookieAccent || 'neutral'

    this.applyScheme()
    this.applyTheme()
    this.applyAccent()

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

  setAccent(event) {
    event.preventDefault()
    const { accent } = event.currentTarget.dataset

    if (!accent) return

    this.currentAccentValue = accent
    this.saveAccent()
    this.applyAccent()

    // Close the dropdown
    if (this.hasAccentPanelTarget) {
      this.accentPanelTarget.setAttribute('hidden', true)
    }
  }

  saveScheme() {
    if (this.currentSchemeValue === 'auto') {
      Cookies.remove('color_scheme')
    } else {
      Cookies.set('color_scheme', this.currentSchemeValue)
    }
  }

  saveTheme() {
    if (this.currentThemeValue === 'brand') {
      Cookies.remove('theme')
    } else {
      Cookies.set('theme', this.currentThemeValue)
    }
  }

  saveAccent() {
    if (this.currentAccentValue === 'neutral') {
      Cookies.remove('accent_color')
    } else {
      Cookies.set('accent_color', this.currentAccentValue)
    }
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

  applyAccent() {
    // Remove all accent classes from body
    const accentColors = ['orange', 'yellow', 'green', 'blue', 'purple', 'pink', 'red', 'teal']
    accentColors.forEach(color => {
      document.body.classList.remove(`accent-${color}`)
    })

    // Add the selected accent class (neutral means no accent class)
    const accent = this.currentAccentValue || 'neutral'
    if (accent !== 'neutral') {
      document.body.classList.add(`accent-${accent}`)
    }
  }
}
