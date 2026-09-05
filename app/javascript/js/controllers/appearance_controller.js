import { Controller } from '@hotwired/stimulus'
import { patch } from '@rails/request.js'
import Cookies from 'js-cookie'

// Four dimensions: the theme (Paper, Coastal, …) and, on top of it, the
// neutral, accent, and scheme picks. A theme owns whichever of the three it
// locks (all of them, by default): while it is active those pickers are
// hidden, the user's picks for them are not applied, and a locked scheme is
// forced. The user's picks are kept, so switching back to a theme that leaves
// a dimension open (Paper) restores them without a reload.
export default class extends Controller {
  static targets = [
    'button',
    'accentOption',
    'themeLabel',
    'themeOption',
    'appearanceThemeOption',
    'appearanceThemeLabel',
    'neutralPicker',
    'accentPicker',
    'schemePicker',
  ]

  // themeLabels: the neutral picker's labels (historical name). appearanceThemeLabels: the theme picker's.
  static values = { themeLabels: Object, appearanceThemeLabels: Object }

  connect() {
    this.appearance = window.Avo?.configuration?.appearance || {}
    this.lockedNeutral = this.appearance.neutralLocked ? this.appearance.neutral : null
    this.lockedAccent = this.appearance.accentLocked ? this.appearance.accent : null
    this.lockedScheme = this.appearance.schemeLocked ? this.appearance.scheme : null
    this.lockedAppearanceTheme = this.appearance.themeLocked ? this.appearance.theme : null

    // The user's own picks come from the server (`picks`), because the
    // classes on <html> already have the active theme's locks applied and
    // would read back a forced value as the user's choice.
    const picks = this.appearance.picks || {}
    this.currentAppearanceThemeValue = this.readCurrentAppearanceTheme()
    this.currentSchemeValue = picks.scheme || this.readCurrentScheme()
    this.currentThemeValue = picks.neutral || this.readCurrentNeutral()
    this.currentAccentValue = picks.accent || this.readCurrentAccent()

    // Sync UI controls to match current state (no re-apply needed — classes are already on <html>)
    this.updateThemeLabel()
    this.updateActiveThemeOption()
    this.updateActiveAccentOption()
    this.updateActiveAppearanceThemeOption()
    this.updateAppearanceThemeLabel()
    this.syncPickerVisibility()

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

  // The theme dimension (Paper, Coastal, …), distinct from the neutral picker
  // that historically used "theme" in its method names below.
  readCurrentAppearanceTheme() {
    const match = Array.from(document.documentElement.classList).find((cls) => cls.startsWith('avo-theme-'))
    return match ? match.replace('avo-theme-', '') : this.appearance.theme || null
  }

  disconnect() {
    if (this.mediaQuery && this.mediaQueryListener) {
      this.mediaQuery.removeEventListener('change', this.mediaQueryListener)
    }
  }

  // --- What the theme owns ---

  themeLocks(id = this.currentAppearanceThemeValue) {
    return (id && this.appearance.themeLocks && this.appearance.themeLocks[id]) || []
  }

  themeLocksDimension(dimension, id = this.currentAppearanceThemeValue) {
    return this.themeLocks(id).includes(dimension)
  }

  // The scheme a theme forces while it locks the scheme picker, or null.
  themeForcedScheme(id = this.currentAppearanceThemeValue) {
    if (!this.themeLocksDimension('scheme', id)) return null
    return (this.appearance.themeSchemes && this.appearance.themeSchemes[id]) || 'light'
  }

  // Hide the pickers the active theme owns. Only on a committed pick, never on
  // hover: the pill would resize under the pointer.
  syncPickerVisibility(id = this.currentAppearanceThemeValue) {
    const locks = this.themeLocks(id)
    if (this.hasNeutralPickerTarget) this.neutralPickerTargets.forEach((el) => { el.hidden = locks.includes('neutral') })
    if (this.hasAccentPickerTarget) this.accentPickerTargets.forEach((el) => { el.hidden = locks.includes('accent') })
    if (this.hasSchemePickerTarget) this.schemePickerTargets.forEach((el) => { el.hidden = locks.includes('scheme') })
  }

  // --- Scheme ---

  setScheme(event) {
    event.preventDefault()
    if (this.lockedScheme || this.themeLocksDimension('scheme')) return

    const { scheme } = event.currentTarget.dataset

    if (!scheme || !['auto', 'light', 'dark'].includes(scheme)) return

    this.currentSchemeValue = scheme
    this.persistPreferences('scheme')
    this.applyScheme()
  }

  // --- Neutral ---

  setNeutral(event) {
    event.preventDefault()
    if (this.lockedNeutral || this.themeLocksDimension('neutral')) return

    const { theme } = event.currentTarget.dataset
    const allowedThemes = this.appearance.neutrals || []

    if (!theme || !allowedThemes.includes(theme)) return

    this.currentThemeValue = theme
    this.persistPreferences('theme')
    this.applyTheme()
    this.updateThemeLabel()
    this.updateActiveThemeOption()
  }

  previewNeutral(event) {
    const { theme } = event.currentTarget.dataset
    if (!theme) return

    this.applyThemeClass(theme)
    this.updateActiveThemeOptionFor(theme)
  }

  revertNeutral() {
    this.applyTheme()
    this.updateActiveThemeOption()
  }

  // Historical names of the neutral picker's actions, kept for ejected partials.
  setTheme(event) { this.setNeutral(event) }

  previewTheme(event) { this.previewNeutral(event) }

  revertTheme() { this.revertNeutral() }

  // --- Theme picker (avo-theme-<id> on <html>) ---

  setAppearanceTheme(event) {
    event.preventDefault()
    if (this.lockedAppearanceTheme) return

    const { appearanceTheme } = event.currentTarget.dataset
    const allowed = this.appearance.themes || []
    if (!appearanceTheme || !allowed.includes(appearanceTheme)) return

    this.commitAppearanceTheme(appearanceTheme)
  }

  previewAppearanceTheme(event) {
    const { appearanceTheme } = event.currentTarget.dataset
    if (!appearanceTheme) return

    this.applyAppearanceTheme(appearanceTheme)
    this.updateActiveAppearanceThemeOptionFor(appearanceTheme)
  }

  revertAppearanceTheme() {
    this.applyAppearanceTheme(this.currentAppearanceThemeValue)
    this.updateActiveAppearanceThemeOption()
  }

  cycleAppearanceTheme() {
    if (this.lockedAppearanceTheme) return
    const allowed = this.appearance.themes || []
    if (allowed.length === 0) return
    this.commitAppearanceTheme(this.nextValue(allowed, this.currentAppearanceThemeValue))
  }

  commitAppearanceTheme(id) {
    const previous = this.currentAppearanceThemeValue
    this.currentAppearanceThemeValue = id
    this.applyAppearanceTheme(id)
    this.syncPickerVisibility(id)
    this.updateActiveAppearanceThemeOption()
    this.updateAppearanceThemeLabel()
    this.updateActiveThemeOption()
    this.updateActiveAccentOption()

    const persisted = this.persistPreferences('appearanceTheme')

    // A theme with partial overrides or brand assets is rendered by the server,
    // so a class swap is not enough: re-render the page once the pick is saved.
    if (this.appearanceThemeNeedsVisit(previous) || this.appearanceThemeNeedsVisit(id)) {
      Promise.resolve(persisted).then(() => this.revisit())
    }
  }

  // The theme class, plus the three dimensions resolved for that theme: a
  // locked one takes the theme's value, an open one the user's pick.
  applyAppearanceTheme(id) {
    this.applyAppearanceThemeClass(id)
    this.applyScheme(id)
    this.applyTheme(id)
    this.applyAccent(id)
  }

  appearanceThemeNeedsVisit(id) {
    return !!id && (this.appearance.themesNeedingVisit || []).includes(id)
  }

  revisit() {
    if (window.Turbo && typeof window.Turbo.visit === 'function') {
      window.Turbo.visit(window.location.href, { action: 'replace' })
    } else {
      window.location.reload()
    }
  }

  applyAppearanceThemeClass(id) {
    const root = document.documentElement
    Array.from(root.classList).forEach((cls) => {
      if (cls.startsWith('avo-theme-')) root.classList.remove(cls)
    })
    if (id) root.classList.add(`avo-theme-${id}`)
  }

  updateActiveAppearanceThemeOption() {
    this.updateActiveAppearanceThemeOptionFor(this.currentAppearanceThemeValue)
  }

  updateActiveAppearanceThemeOptionFor(active) {
    if (!this.hasAppearanceThemeOptionTarget) return

    this.appearanceThemeOptionTargets.forEach((option) => {
      const { appearanceTheme } = option.dataset
      if (!appearanceTheme) return

      option.classList.toggle('color-scheme-switcher__theme-option--active', appearanceTheme === active)
    })
  }

  updateAppearanceThemeLabel() {
    if (!this.hasAppearanceThemeLabelTarget) return

    const id = this.currentAppearanceThemeValue
    const labels = this.hasAppearanceThemeLabelsValue ? this.appearanceThemeLabelsValue : {}
    this.appearanceThemeLabelTarget.textContent = labels[id] || (id ? id.charAt(0).toUpperCase() + id.slice(1) : '')

    // The pill's tile previews the active theme; retarget its class too.
    const tile = this.appearanceThemeLabelTarget.parentElement?.querySelector('.theme-tile')
    if (tile) {
      Array.from(tile.classList).forEach((cls) => {
        if (cls.startsWith('avo-theme-')) tile.classList.remove(cls)
      })
      if (id) tile.classList.add(`avo-theme-${id}`)
    }
  }

  // --- Accent ---

  setAccent(event) {
    event.preventDefault()
    if (this.lockedAccent || this.themeLocksDimension('accent')) return

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

  // Cycle to the next value in a list. Wraps to the first when at the end.
  // Used by the global keyboard shortcuts (see global_hotkeys.js).
  cycleScheme() {
    if (this.lockedScheme || this.themeLocksDimension('scheme')) return
    this.currentSchemeValue = this.nextValue(['auto', 'light', 'dark'], this.currentSchemeValue)
    this.persistPreferences('scheme')
    this.applyScheme()
  }

  cycleNeutral() {
    if (this.lockedNeutral || this.themeLocksDimension('neutral')) return
    const allowed = this.appearance.neutrals || []
    if (allowed.length === 0) return
    this.currentThemeValue = this.nextValue(allowed, this.currentThemeValue || 'brand')
    this.persistPreferences('theme')
    this.applyTheme()
    this.updateThemeLabel()
    this.updateActiveThemeOption()
  }

  cycleAccent() {
    if (this.lockedAccent || this.themeLocksDimension('accent')) return
    const allowed = this.appearance.accents || []
    if (allowed.length === 0) return
    this.currentAccentValue = this.nextValue(allowed, this.currentAccentValue || 'brand')
    this.persistPreferences('accent')
    this.applyAccent()
    this.updateActiveAccentOption()
  }

  nextValue(list, current) {
    const idx = list.indexOf(current)
    return list[(idx + 1) % list.length]
  }

  // Returns a promise when persistence is asynchronous (database), so callers
  // that must re-render afterwards can wait for it.
  persistPreferences(dimension) {
    if (this.appearance.persistence === 'database') {
      return this.patchAppearanceSettings(dimension)
    }

    this.writePreferenceCookie(dimension)
    return null
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
      case 'appearanceTheme':
        this.setPreferenceCookie(this.appearanceThemeCookieName(), this.currentAppearanceThemeValue, this.appearanceDefaultTheme())
        break
      default:
        break
    }
  }

  appearanceThemeCookieName() {
    return `${window.Avo?.configuration?.cookies_key || 'avo'}.theme`
  }

  // Mirrors ThemeManager#default: the configured theme, else the first offered one.
  appearanceDefaultTheme() {
    // Not `t`: i18n-tasks' scanner reads a bare `t` as a translation call.
    const configured = this.appearance.theme
    if (configured != null && configured !== '') return String(configured)
    const themes = this.appearance.themes || []
    return themes.length > 0 ? themes[0] : ''
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

    return patch(`${window.Avo.configuration.root_path}/appearance_settings`, {
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
      case 'appearanceTheme':
        return { theme: this.currentAppearanceThemeValue }
      default:
        return null
    }
  }

  // --- Applying classes to <html> ---

  // The scheme for a theme: the one it forces, else the user's pick.
  applyScheme(themeId = this.currentAppearanceThemeValue) {
    const scheme = this.themeForcedScheme(themeId) || this.currentSchemeValue || 'auto'

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

  // The neutral for a theme: none while the theme owns it, else the user's pick.
  applyTheme(themeId = this.currentAppearanceThemeValue) {
    this.applyThemeClass(this.themeLocksDimension('neutral', themeId) ? 'brand' : this.currentThemeValue || 'brand')
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

  // The accent for a theme: none while the theme owns it, else the user's pick.
  applyAccent(themeId = this.currentAppearanceThemeValue) {
    this.applyAccentClass(this.themeLocksDimension('accent', themeId) ? 'brand' : this.currentAccentValue || 'brand')
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

    const labels = this.hasThemeLabelsValue ? this.themeLabelsValue : {}
    const label = labels[theme] || theme.charAt(0).toUpperCase() + theme.slice(1)
    this.themeLabelTarget.textContent = label
  }

  // Mirrors the Shift+K hotkey in global_hotkeys.js. CSS handles the active
  // state via [data-key-badges] selectors against `:root.hotkeys-hide-badges`.
  setKeyBadges(event) {
    event.preventDefault()
    const { keyBadges } = event.currentTarget.dataset
    if (keyBadges !== 'show' && keyBadges !== 'hide') return

    const hide = keyBadges === 'hide'
    document.documentElement.classList.toggle('hotkeys-hide-badges', hide)
    try {
      if (hide) {
        localStorage.setItem('avo:hotkeys:hide_badges', '1')
      } else {
        localStorage.removeItem('avo:hotkeys:hide_badges')
      }
    } catch (e) {
      // localStorage unavailable (private browsing) — toggle works for the current session only
    }
  }
}
