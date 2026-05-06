import { Controller } from '@hotwired/stimulus'
import { patch } from '@rails/request.js'
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
    this.persistPreferences('scheme')
    this.applyScheme()
  }

  setTheme(event) {
    event.preventDefault()
    if (this.lockedNeutral) return

    const { theme } = event.currentTarget.dataset
    const allowedThemes = ['brand', ...(this.branding.neutrals || [])]

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

    if (!accent) return

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
    if (this.branding.persistence === 'database') {
      this.patchThemeSettings(dimension)
      return
    }

    this.writePreferenceCookie(dimension)
  }

  writePreferenceCookie(dimension) {
    switch (dimension) {
      case 'scheme':
        this.setPreferenceCookie('color_scheme', this.currentSchemeValue, this.brandingDefaultScheme())
        break
      case 'theme':
        this.setPreferenceCookie('theme', this.currentThemeValue, this.brandingDefaultNeutral())
        break
      case 'accent':
        this.setPreferenceCookie('accent_color', this.currentAccentValue, this.brandingDefaultAccent())
        break
      default:
        break
    }
  }

  // Match ApplicationHelper#current_* fallbacks so we only drop cookies when the value
  // equals the configured branding default (not hardcoded :auto / :brand / :neutral).
  brandingDefaultScheme() {
    const s = this.branding.scheme
    return s != null && s !== '' ? String(s) : 'auto'
  }

  brandingDefaultNeutral() {
    const n = this.branding.neutral
    return n != null && n !== '' ? String(n) : 'brand'
  }

  brandingDefaultAccent() {
    const a = this.branding.accent
    return a != null && a !== '' ? String(a) : 'neutral'
  }

  setPreferenceCookie(name, value, defaultValue) {
    if (value === defaultValue) {
      Cookies.remove(name)
    } else {
      Cookies.set(name, value)
    }
  }

  patchThemeSettings(dimension) {
    const body = this.themeSettingsPayload(dimension)
    if (!body) return

    patch(`${window.Avo.configuration.root_path}/theme_settings`, {
      responseKind: 'json',
      contentType: 'application/json',
      body,
    })
  }

  themeSettingsPayload(dimension) {
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
