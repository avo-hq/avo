import { Controller } from '@hotwired/stimulus'
import { patch } from '@rails/request.js'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentOption', 'themeLabel', 'themeOption']

  connect() {
    this.appearance = window.Avo?.configuration?.appearance || {}
    this.lockedNeutral = this.appearance.neutralLocked ? this.appearance.neutral : null
    this.lockedAccent = this.appearance.accentLocked ? this.appearance.accent : null
    this.lockedScheme = this.appearance.schemeLocked ? this.appearance.scheme : null

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
    const match = Array.from(document.documentElement.classList).find((cls) => cls.startsWith('accent-theme-'))
    return match ? match.replace('accent-theme-', '') : 'brand'
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
    this.persistPreferences('scheme')
    this.applyScheme()
  }

  setTheme(event) {
    event.preventDefault()
    if (this.lockedNeutral) return

    const { theme } = event.currentTarget.dataset
    const allowedThemes = this.appearance.neutrals || []

    if (!theme || !allowedThemes.includes(theme)) return

    this.currentThemeValue = theme
    this.persistPreferences('theme')
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
    const allowedAccents = this.appearance.accents || []

    if (!accent || !allowedAccents.includes(accent)) return

    this.currentAccentValue = accent
    this.persistPreferences('accent')
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

  persistPreferences(dimension) {
    if (this.appearance.persistence === 'database') {
      this.patchAppearanceSettings(dimension)
      return
    }

    this.writePreferenceCookie(dimension)
  }

  writePreferenceCookie(dimension) {
    switch (dimension) {
      case 'scheme':
        this.setPreferenceCookie('color_scheme', this.currentSchemeValue, this.appearanceDefaultScheme())
        break
      case 'theme':
        this.setPreferenceCookie('theme', this.currentThemeValue, this.appearanceDefaultNeutral())
        break
      case 'accent':
        this.setPreferenceCookie('accent_color', this.currentAccentValue, this.appearanceDefaultAccent())
        break
      default:
        break
    }
  }

  // Match ApplicationHelper#current_* fallbacks so we only drop cookies when the value
  // equals the configured default (not hardcoded :auto / :brand / :neutral).
  appearanceDefaultScheme() {
    const s = this.appearance.scheme
    return s != null && s !== '' ? String(s) : 'auto'
  }

  appearanceDefaultNeutral() {
    const n = this.appearance.neutral
    return n != null && n !== '' ? String(n) : 'brand'
  }

  appearanceDefaultAccent() {
    const a = this.appearance.accent
    return a != null && a !== '' ? String(a) : 'brand'
  }

  setPreferenceCookie(name, value, defaultValue) {
    if (value === defaultValue) {
      Cookies.remove(name)
    } else {
      Cookies.set(name, value)
    }
  }

  patchAppearanceSettings(dimension) {
    const body = this.appearanceSettingsPayload(dimension)
    if (!body) return

    patch(`${window.Avo.configuration.root_path}/appearance_settings`, {
      responseKind: 'json',
      contentType: 'application/json',
      body,
    })
  }

  appearanceSettingsPayload(dimension) {
    switch (dimension) {
      case 'scheme':
        return { color_scheme: this.currentSchemeValue }
      case 'theme':
        return { neutral: this.currentThemeValue }
      case 'accent':
        return { accent: this.currentAccentValue }
      default:
        return null
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
    this.applyAccentClass(this.currentAccentValue || 'brand')
  }

  applyAccentClass(accent) {
    const root = document.documentElement
    Array.from(root.classList).forEach((cls) => {
      if (cls.startsWith('accent-theme-')) root.classList.remove(cls)
    })

    if (accent !== 'brand') {
      root.classList.add(`accent-theme-${accent}`)
    }
  }

  updateActiveAccentOption() {
    this.updateActiveAccentOptionFor(this.currentAccentValue || 'brand')
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
