import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentOption', 'themeLabel', 'themeOption', 'resetButton']

  static values = {
    mode: { type: String, default: 'static' },
    persistence: { type: String, default: 'localstorage' },
  }

  connect() {
    const branding = document.querySelector('meta[name="avo-branding"]')?.dataset || {}
    this.lockedNeutral = this.modeValue === 'static' && branding.lockedNeutral ? branding.lockedNeutral : null
    this.lockedAccent = this.modeValue === 'static' && branding.lockedAccent ? branding.lockedAccent : null
    this.lockedScheme = branding.lockedScheme || null

    // Read current state from server-rendered <html> classes
    this.currentSchemeValue = this.readCurrentScheme()
    this.currentThemeValue = this.readCurrentNeutral()
    this.currentAccentValue = this.readCurrentAccent()

    // Sync UI controls to match current state (no re-apply needed — classes are already on <html>)
    this.updateThemeLabel()
    this.updateActiveThemeOption()
    this.updateActiveAccentOption()
    this.updateResetButton()

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
    const root = document.documentElement
    const neutrals = ['slate', 'stone', 'gray', 'zinc', 'neutral', 'taupe', 'mauve', 'mist', 'olive']
    for (const name of neutrals) {
      if (root.classList.contains(`theme-neutral-${name}`)) return name
    }
    return 'brand'
  }

  readCurrentAccent() {
    const root = document.documentElement
    const accents = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
    for (const name of accents) {
      if (root.classList.contains(`theme-accent-${name}`)) return name
    }
    return 'neutral'
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
    this.updateResetButton()
  }

  setTheme(event) {
    event.preventDefault()
    if (this.lockedNeutral) return

    const { theme } = event.currentTarget.dataset

    if (!theme || !['brand', 'slate', 'stone', 'gray', 'zinc', 'neutral', 'taupe', 'mauve', 'mist', 'olive'].includes(theme)) return

    this.currentThemeValue = theme
    this.saveTheme()
    this.applyTheme()
    this.updateThemeLabel()
    this.updateActiveThemeOption()
    this.updateResetButton()
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
    this.updateResetButton()
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

  resetSettings() {
    Cookies.remove('color_scheme')
    Cookies.remove('theme')
    Cookies.remove('accent_color')

    this.currentSchemeValue = 'auto'
    this.currentThemeValue = 'brand'
    this.currentAccentValue = 'neutral'

    this.applyScheme()
    this.applyTheme()
    this.applyAccent()
    this.updateThemeLabel()
    this.updateActiveThemeOption()
    this.updateActiveAccentOption()
    this.updateResetButton()
    this.persistToDatabase()
  }

  hasCustomSettings() {
    return this.currentSchemeValue !== 'auto'
      || this.currentThemeValue !== 'brand'
      || this.currentAccentValue !== 'neutral'
  }

  updateResetButton() {
    if (!this.hasResetButtonTarget) return

    this.resetButtonTarget.hidden = !this.hasCustomSettings()
  }

  saveScheme() {
    if (this.currentSchemeValue === 'auto') {
      Cookies.remove('color_scheme')
    } else {
      Cookies.set('color_scheme', this.currentSchemeValue)
    }
    this.persistToDatabase()
  }

  saveTheme() {
    if (this.currentThemeValue === 'brand') {
      Cookies.remove('theme')
    } else {
      Cookies.set('theme', this.currentThemeValue)
    }
    this.persistToDatabase()
  }

  saveAccent() {
    if (this.currentAccentValue === 'neutral') {
      Cookies.remove('accent_color')
    } else {
      Cookies.set('accent_color', this.currentAccentValue)
    }
    this.persistToDatabase()
  }

  persistToDatabase() {
    if (this.persistenceValue !== 'database') return

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
    document.documentElement.classList.remove('theme-neutral-slate', 'theme-neutral-stone', 'theme-neutral-gray', 'theme-neutral-zinc', 'theme-neutral-neutral', 'theme-neutral-taupe', 'theme-neutral-mauve', 'theme-neutral-mist', 'theme-neutral-olive')

    if (theme !== 'brand') {
      document.documentElement.classList.add(`theme-neutral-${theme}`)
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
    const accentColors = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
    accentColors.forEach((color) => {
      document.documentElement.classList.remove(`theme-accent-${color}`)
    })

    if (accent !== 'neutral') {
      document.documentElement.classList.add(`theme-accent-${accent}`)
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
