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
