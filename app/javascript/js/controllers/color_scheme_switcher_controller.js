import { Controller } from '@hotwired/stimulus'
import Cookies from 'js-cookie'

export default class extends Controller {
  static targets = ['button', 'accentPanel', 'accentOption', 'themePanel', 'themeLabel', 'themeOption']

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
    this.updateThemeLabel()
    this.updateActiveThemeOption()

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

    if (!theme || !['brand', 'slate', 'stone', 'gray', 'zinc', 'neutral', 'taupe', 'mauve', 'mist', 'olive'].includes(theme)) return

    this.currentThemeValue = theme
    this.saveTheme()
    this.applyTheme()
    this.updateThemeLabel()
    this.updateActiveThemeOption()

    // Close the dropdown
    if (this.hasThemePanelTarget) {
      this.themePanelTarget.setAttribute('hidden', true)
    }
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
    this.applyThemeClass(this.currentThemeValue || 'brand')
  }

  applyThemeClass(theme) {
    document.documentElement.classList.remove('theme-slate', 'theme-stone', 'theme-gray', 'theme-zinc', 'theme-neutral', 'theme-taupe', 'theme-mauve', 'theme-mist', 'theme-olive')

    if (theme !== 'brand') {
      document.documentElement.classList.add(`theme-${theme}`)
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
      document.documentElement.classList.remove(`accent-${color}`)
    })

    if (accent !== 'neutral') {
      document.documentElement.classList.add(`accent-${accent}`)
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
