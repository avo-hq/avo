/**
 * Global (non-element) keyboard shortcuts.
 * Add new entries to HOTKEYS to register more.
 *
 * Two registries:
 *   - ELEMENT_HOTKEYS: handled via @github/hotkey (supports sequences like "r r r")
 *   - DIRECT_HOTKEYS: custom keydown listeners for keys needing cross-browser normalization
 */

import { install } from '@github/hotkey'

const RESOURCE_SEARCH_INPUT_SELECTOR = '[data-resource-search-target="input"]'
const findResourceSearchInput = () => document.querySelector(RESOURCE_SEARCH_INPUT_SELECTOR)

const RESOURCE_TABLE_SELECTOR = '[data-index-row-navigator-target="table"]'
const findResourceTable = () => document.querySelector(RESOURCE_TABLE_SELECTOR)

// The resource's index path is exposed via a <meta> tag only on show/edit pages,
// letting the "i" hotkey return to the listing from a single record.
const findResourcesIndexPath = () => {
  const path = document.querySelector('meta[name="avo:resources-index-path"]')?.getAttribute('content')
  return path && path.length ? path : null
}

// The content-focus point is the entry into each screen's main content: the
// index table, the grid wrapper, or a show/edit panel body. Focusing it lets the
// user immediately Tab into the content (and Shift+Tab back to the page controls).
const CONTENT_FOCUS_SELECTOR = '[data-content-focus]'

// Tabbed show/edit views render every panel with data-content-focus, but inactive
// tab panels stay in the DOM with a hidden class. Skip those so Shift+T lands on
// the content the user is actually viewing.
const isVisibleContentFocus = (element) => {
  if (!element) return false
  if (element.closest('[hidden], .hidden')) return false

  return element.getClientRects().length > 0
}

const isModalOpen = () => document.body.classList.contains('modal-open')

const findContentFocus = () => {
  // Show/edit panel bodies stay in the layout behind open modals (e.g. attach
  // media). Without this guard, Shift+T would focus obscured page content.
  if (isModalOpen()) return null

  return Array.from(document.querySelectorAll(CONTENT_FOCUS_SELECTOR)).find(isVisibleContentFocus) ?? null
}

// Find any mounted appearance Stimulus controller and call `method` on it.
// Multiple appearance switchers can be on the page (inline + dropdown fallback);
// either works since they share state via DOM classes + cookies/database.
function callAppearance(method) {
  const el = document.querySelector('[data-controller~="appearance"]')
  if (!el) return
  const controller = window.Stimulus?.getControllerForElementAndIdentifier(el, 'appearance')
  controller?.[method]?.()
}

// Use @github/hotkey for sequences and standard combos.
const ELEMENT_HOTKEYS = [
  {
    hotkey: 'r r r',
    handle: () => {
      window.reloadScrollTop = document.querySelector('.scrollable-wrapper')?.scrollTop
      window.StreamActions.turbo_reload()
    },
  },
]

// Use direct listeners for keys where event.key varies across browsers/layouts.
const DIRECT_HOTKEYS = [
  {
    // Shift+/ → "?" on US layouts, but some browsers expose key:"Slash"+shiftKey instead.
    match: (e) => e.key === '?' || (e.shiftKey && e.code === 'Slash'),
    handle: () => document.dispatchEvent(new Event('persistent-modal:toggle')),
  },
  {
    // "/" → focus the resource search input on index pages.
    match: (e) => e.key === '/'
      && !e.shiftKey
      && !e.metaKey
      && !e.ctrlKey
      && !e.altKey
      && !!findResourceSearchInput(),
    handle: () => {
      const input = findResourceSearchInput()
      if (input) input.focus()
    },
  },
  {
    // i → return to the resource's index page (from a show/edit page).
    match: (e) => e.key === 'i' && !e.shiftKey && !e.metaKey && !e.ctrlKey && !e.altKey && !isModalOpen() && !!findResourcesIndexPath(),
    handle: () => {
      const path = findResourcesIndexPath()
      if (!path) return
      if (window.Turbo) {
        window.Turbo.visit(path)
      } else {
        window.location.assign(path)
      }
    },
  },
  {
    // Shift+M → cycle appearance scheme (auto → light → dark → …)
    match: (e) => e.shiftKey && e.key === 'M',
    handle: () => callAppearance('cycleScheme'),
  },
  {
    // Shift+N → cycle neutral theme (brand → slate → stone → …)
    match: (e) => e.shiftKey && e.key === 'N',
    handle: () => callAppearance('cycleNeutral'),
  },
  {
    // Shift+A → cycle accent color (brand → red → orange → …)
    match: (e) => e.shiftKey && e.key === 'A',
    handle: () => callAppearance('cycleAccent'),
  },
  {
    // Shift+T → focus the screen's main content (table rows, grid cards, or panel
    // fields). From there, Tab dives in and Shift+Tab returns to the page controls.
    match: (e) => e.shiftKey && e.key === 'T' && !!findContentFocus(),
    handle: () => findContentFocus()?.focus({ preventScroll: true }),
  },
  {
    // j → focus the resource table AND move to the next row (Gmail/GitHub style)
    match: (e) => e.key === 'j' && !e.shiftKey && !e.metaKey && !e.ctrlKey && !e.altKey && !!findResourceTable(),
    handle: () => {
      findResourceTable()?.focus({ preventScroll: true })
      document.dispatchEvent(new CustomEvent('avo:advance-resource-table', { detail: { direction: 'next' } }))
    },
  },
  {
    // k → focus the resource table AND move to the previous row
    match: (e) => e.key === 'k' && !e.shiftKey && !e.metaKey && !e.ctrlKey && !e.altKey && !!findResourceTable(),
    handle: () => {
      findResourceTable()?.focus({ preventScroll: true })
      document.dispatchEvent(new CustomEvent('avo:advance-resource-table', { detail: { direction: 'previous' } }))
    },
  },
  {
    // Shift+K → toggle kbd badge visibility (only when developer config allows badges)
    match: (e) => e.shiftKey && e.key === 'K'
      && window.Avo?.configuration?.hotkeys?.showKeyBadges !== false,
    handle: () => {
      document.documentElement.classList.toggle('hotkeys-hide-badges')
      const hidden = document.documentElement.classList.contains('hotkeys-hide-badges')
      try {
        if (hidden) {
          localStorage.setItem('avo:hotkeys:hide_badges', '1')
        } else {
          localStorage.removeItem('avo:hotkeys:hide_badges')
        }
      } catch (e) {
        // localStorage unavailable (private browsing) — toggle works for current session only
      }
    },
  },
]

const TYPING_SELECTOR = 'input, textarea, select, [contenteditable]'

// hotkey-fire is dispatched with { cancelable: true } but NOT { bubbles: true },
// so it never reaches a document-level listener. Must be registered on each element.
function hotkeyFireHandler(event) {
  const el = event.currentTarget
  const hotkey = el.getAttribute('data-hotkey')

  // Apply feedback to ALL elements sharing this hotkey (e.g. desktop + mobile sidebar).
  // @github/hotkey fires on the last-registered element which may be hidden.
  const kbds = hotkey
    ? document.querySelectorAll(`[data-hotkey="${CSS.escape(hotkey)}"] kbd`)
    : el.querySelectorAll('kbd')

  if (!kbds.length) return

  event.preventDefault()
  kbds.forEach((kbd) => {
    kbd.classList.add('kbd--called')
    kbd.addEventListener('transitionend', () => kbd.classList.remove('kbd--called'), { once: true })
  })
  // Double rAF: the first fires before paint (style committed), the second
  // fires after the browser has actually painted the kbd--called state.
  requestAnimationFrame(() => {
    requestAnimationFrame(() => el.click())
  })
}

export function attachHotkeyFeedback(el) {
  el.removeEventListener('hotkey-fire', hotkeyFireHandler)
  el.addEventListener('hotkey-fire', hotkeyFireHandler)
}

export function installGlobalHotkeys() {
  if (window.Avo?.configuration?.hotkeys?.enabled === false) return

  document.addEventListener('turbo:load', () => {
    document.querySelectorAll('kbd.kbd--called').forEach((kbd) => kbd.classList.remove('kbd--called'))

    if (window.reloadScrollTop) {
      setTimeout(() => {
        document.querySelector('.scrollable-wrapper')?.scrollTo(0, window.reloadScrollTop)
        window.reloadScrollTop = null
      }, 50)
    }
  })

  ELEMENT_HOTKEYS.forEach(({ hotkey, handle }) => {
    const el = document.createElement('span')
    el.addEventListener('hotkey-fire', (event) => {
      event.preventDefault()
      handle()
    })
    install(el, hotkey)
  })

  document.addEventListener('keydown', (event) => {
    if (event.defaultPrevented || event.repeat) return
    if (event.target instanceof Element && event.target.closest(TYPING_SELECTOR)) return

    const entry = DIRECT_HOTKEYS.find(({ match }) => match(event))
    if (entry) {
      event.preventDefault()
      entry.handle()
    }
  })
}
