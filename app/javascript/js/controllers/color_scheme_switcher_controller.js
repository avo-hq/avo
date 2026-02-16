import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentPanel', 'saveButton', 'saveWrapper']

  static values = {
    saveUrl: String,
    persistable: Boolean,
  }

  connect() {
    // Read from cookies (cookie is source of truth)
    const cookieScheme = Cookies.get('color_scheme')
    const cookieTheme = Cookies.get('theme')
    const cookieAccent = Cookies.get('accent_color')

    // Use cookie value if it exists, otherwise use default
    this.currentSchemeValue = cookieScheme || 'auto'
    this.currentThemeValue = cookieTheme || 'brand'
    this.currentAccentValue = cookieAccent || 'neutral'

    // Snapshot the saved state so we can detect unsaved changes
    this.snapshotSavedState()

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
    this.updateSaveButtonState()
  }

  setTheme(event) {
    event.preventDefault()
    const { theme } = event.currentTarget.dataset

    if (!theme || !['brand', 'slate', 'stone'].includes(theme)) return

    this.currentThemeValue = theme
    this.saveTheme()
    this.applyTheme()
    this.updateSaveButtonState()
  }

  setAccent(event) {
    event.preventDefault()
    const { accent } = event.currentTarget.dataset

    if (!accent) return

    this.currentAccentValue = accent
    this.saveAccent()
    this.applyAccent()
    this.updateSaveButtonState()

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

  // Snapshot the current state as "saved" — used to detect unsaved changes
  snapshotSavedState() {
    this.savedScheme = this.currentSchemeValue
    this.savedTheme = this.currentThemeValue
    this.savedAccent = this.currentAccentValue
    this.updateSaveButtonState()
  }

  // Check if current preferences differ from the last saved state
  hasUnsavedChanges() {
    return this.currentSchemeValue !== this.savedScheme
           || this.currentThemeValue !== this.savedTheme
           || this.currentAccentValue !== this.savedAccent
  }

  // Show/hide the save button wrapper based on dirty state
  updateSaveButtonState() {
    if (!this.hasSaveWrapperTarget) return

    if (this.hasUnsavedChanges()) {
      this.saveWrapperTarget.classList.add('color-scheme-switcher__save-wrapper--visible')
    } else {
      this.saveWrapperTarget.classList.remove('color-scheme-switcher__save-wrapper--visible')
    }
  }

  // Collect all current preference values from cookies
  collectPreferences() {
    return {
      color_scheme: Cookies.get('color_scheme') || 'auto',
      theme: Cookies.get('theme') || 'brand',
      accent_color: Cookies.get('accent_color') || 'neutral',
    }
  }

  // Save preferences to server via PATCH
  async save(event) {
    event.preventDefault()

    if (!this.persistableValue || !this.saveUrlValue) return

    const button = this.hasSaveButtonTarget ? this.saveButtonTarget : event.currentTarget
    const preferences = this.collectPreferences()

    button.disabled = true

    try {
      const response = await fetch(this.saveUrlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content,
        },
        body: JSON.stringify({ preferences }),
      })

      if (response.ok) {
        this.showSaveSuccess(button)
        this.dispatch('saved', { detail: { preferences } })

        // Collapse the button after showing success feedback
        setTimeout(() => {
          this.snapshotSavedState()
        }, 1500)
      } else {
        this.showSaveError(button)
      }
    } catch {
      this.showSaveError(button)
    }
  }

  showSaveSuccess(button) {
    button.classList.add('color-scheme-switcher__save--success')
    setTimeout(() => {
      button.classList.remove('color-scheme-switcher__save--success')
    }, 2000)
  }

  showSaveError(button) {
    button.classList.add('color-scheme-switcher__save--error')
    setTimeout(() => {
      button.classList.remove('color-scheme-switcher__save--error')
    }, 2000)
  }

  // Public API: set any cookie-based preference
  setPreference(key, value) {
    const builtInKeys = ['color_scheme', 'theme', 'accent_color']

    if (builtInKeys.includes(key)) {
      Cookies.set(key, value)
    } else {
      // Custom keys use avo. prefix
      Cookies.set(`avo.${key}`, value)
    }
  }

  // Public API: read any cookie-based preference
  getPreference(key) {
    const builtInKeys = ['color_scheme', 'theme', 'accent_color']

    if (builtInKeys.includes(key)) {
      return Cookies.get(key)
    }

    return Cookies.get(`avo.${key}`)
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
    const accentColors = ['red', 'orange', 'amber', 'yellow', 'lime', 'green', 'emerald', 'teal', 'cyan', 'sky', 'blue', 'indigo', 'violet', 'purple', 'fuchsia', 'pink', 'rose']
    accentColors.forEach((color) => {
      document.documentElement.classList.remove(`accent-${color}`)
    })

    // Add the selected accent class (neutral means no accent class)
    const accent = this.currentAccentValue || 'neutral'
    if (accent !== 'neutral') {
      document.documentElement.classList.add(`accent-${accent}`)
    }
  }
}
