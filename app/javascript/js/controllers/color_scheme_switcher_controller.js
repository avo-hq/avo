import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentOption', 'themeLabel', 'themeOption']

  connect() {
    this.branding = window.Avo?.configuration?.branding || {}
    this.lockedNeutral = this.branding.neutralLocked ? this.branding.neutral : null
    this.lockedAccent = this.branding.accentLocked ? this.branding.accent : null
    this.lockedScheme = this.branding.schemeLocked ? this.branding.scheme : null

    // Read current state from server-rendered <html> classes
    this.currentSchemeValue = this.readCurrentScheme()
    this.currentThemeValue = this.readCurrentNeutral()
    this.currentAccentValue = this.readCurrentAccent()

    // Sync UI controls to match current state (no re-apply needed — classes are already on <html>)
    this.updateThemeLabel()
    this.updateActiveThemeOption()
    this.updateActiveAccentOption()

    // Watch for live changes when the user has "auto" as the default setting
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    this.mediaQueryListener = () => {
      if (this.currentSchemeValue === 'auto') {
        this.applyScheme()
      }
    }
    this.mediaQuery.addEventListener('change', this.mediaQueryListener)
  }

  readCurrentScheme() {
    const root = document.documentElement
    if (root.classList.contains('scheme-dark')) return 'dark'
    if (root.classList.contains('scheme-light')) return 'light'
    return 'auto'
  }

  readCurrentNeutral() {
    const match = Array.from(document.documentElement.classList).find((cls) => cls.startsWith('neutral-theme-'))
    return match ? match.replace('neutral-theme-', '') : 'brand'
  }

  readCurrentAccent() {
    const match = Array.from(document.documentElement.classList).find((cls) => cls.startsWith('theme-accent-'))
    return match ? match.replace('theme-accent-', '') : 'neutral'
  }

  disconnect() {
    if (this.mediaQuery && this.mediaQueryListener) {
      this.mediaQuery.removeEventListener('change', this.mediaQueryListener)
    }
  }

  setScheme(event) {
    event.preventDefault()
    if (this.lockedScheme) return

    const { scheme } = event.currentTarget.dataset

    if (!scheme || !['auto', 'light', 'dark'].includes(scheme)) return

    this.currentSchemeValue = scheme
    this.saveScheme()
    this.applyScheme()
  }

  setTheme(event) {
    event.preventDefault()
    if (this.lockedNeutral) return

    const { theme } = event.currentTarget.dataset
    const allowedThemes = ['brand', ...(this.branding.neutrals || [])]

    if (!theme || !allowedThemes.includes(theme)) return

    this.currentThemeValue = theme
    this.saveTheme()
    this.applyTheme()
    this.updateThemeLabel()
    this.updateActiveThemeOption()
  }

  previewTheme(event) {
    const { theme } = event.currentTarget.dataset
    if (!theme) return

    this.applyThemeClass(theme)
    this.updateActiveThemeOptionFor(theme)
  }

  revertTheme() {
    this.applyTheme()
    this.updateActiveThemeOption()
  }

  setAccent(event) {
    event.preventDefault()
    if (this.lockedAccent) return

    const { accent } = event.currentTarget.dataset

    if (!accent) return

    this.currentAccentValue = accent
    this.saveAccent()
    this.applyAccent()
  }

  previewAccent(event) {
    const { accent } = event.currentTarget.dataset
    if (!accent) return

    this.applyAccentClass(accent)
    this.updateActiveAccentOptionFor(accent)
  }

  revertAccent() {
    this.applyAccent()
    this.updateActiveAccentOption()
  }

  saveScheme() {
    this.saveCookie('color_scheme', this.currentSchemeValue, 'auto')
    this.persistToDatabase()
  }

  saveTheme() {
    this.saveCookie('theme', this.currentThemeValue, 'brand')
    this.persistToDatabase()
  }

  saveAccent() {
    this.saveCookie('accent_color', this.currentAccentValue, 'neutral')
    this.persistToDatabase()
  }

  saveCookie(name, value, defaultValue) {
    if (this.branding.persistence === 'database') return

    if (value === defaultValue) {
      Cookies.remove(name)
    } else {
      Cookies.set(name, value)
    }
  }

  persistToDatabase() {
    if (this.branding.persistence !== 'database') return

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    const headers = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    }
    if (csrfToken) headers['X-CSRF-Token'] = csrfToken

    fetch(`${window.Avo.configuration.root_path}/theme_settings`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify({
        color_scheme: this.currentSchemeValue,
        neutral: this.currentThemeValue,
        accent: this.currentAccentValue,
      }),
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
    this.applyThemeClass(this.currentThemeValue || 'brand')
  }

  applyThemeClass(theme) {
    const root = document.documentElement
    Array.from(root.classList).forEach((cls) => {
      if (cls.startsWith('neutral-theme-')) root.classList.remove(cls)
    })

    if (theme !== 'brand') {
      root.classList.add(`neutral-theme-${theme}`)
    }
  }

  updateActiveThemeOption() {
    this.updateActiveThemeOptionFor(this.currentThemeValue || 'brand')
  }

  updateActiveThemeOptionFor(activeTheme) {
    if (!this.hasThemeOptionTarget) return

    this.themeOptionTargets.forEach((option) => {
      const { theme } = option.dataset
      if (!theme) return

      option.classList.toggle('color-scheme-switcher__theme-option--active', theme === activeTheme)
    })
  }

  applyAccent() {
    this.applyAccentClass(this.currentAccentValue || 'neutral')
  }

  applyAccentClass(accent) {
    const root = document.documentElement
    Array.from(root.classList).forEach((cls) => {
      if (cls.startsWith('theme-accent-')) root.classList.remove(cls)
    })

    if (accent !== 'neutral') {
      root.classList.add(`theme-accent-${accent}`)
    }
  }

  updateActiveAccentOption() {
    this.updateActiveAccentOptionFor(this.currentAccentValue || 'neutral')
  }

  updateActiveAccentOptionFor(activeAccent) {
    if (!this.hasAccentOptionTarget) return

    this.accentOptionTargets.forEach((option) => {
      const { accent } = option.dataset
      if (!accent) return

      option.classList.toggle('color-scheme-switcher__accent-option--active', accent === activeAccent)
    })
  }

  updateThemeLabel() {
    this.updateThemeLabelText(this.currentThemeValue || 'brand')
  }

  updateThemeLabelText(theme) {
    if (!this.hasThemeLabelTarget) return

    this.themeLabelTarget.textContent = theme.charAt(0).toUpperCase() + theme.slice(1)
  }
}
