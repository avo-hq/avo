/**
 * Global (non-element) keyboard shortcuts.
 * Add new entries to HOTKEYS to register more.
 *
 * Two registries:
 *   - ELEMENT_HOTKEYS: handled via @github/hotkey (supports sequences like "r r r")
 *   - DIRECT_HOTKEYS: custom keydown listeners for keys needing cross-browser normalization
 */

import { install } from '@github/hotkey'

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
    match: (e) => e.key === '/' && !e.shiftKey && !e.metaKey && !e.ctrlKey && !e.altKey,
    handle: () => {
      const input = document.querySelector('[data-resource-search-target="input"]')
      if (input) input.focus()
    },
  },
]

const TYPING_SELECTOR = 'input, textarea, select, [contenteditable]'

export function installGlobalHotkeys() {
  // When a hotkey fires on a DOM element that contains a <kbd>, mark it cold
  // before letting the click proceed. preventDefault + requestAnimationFrame
  // gives the browser one frame to paint the cold state before navigation starts.
  document.addEventListener('hotkey-fire', (event) => {
    const kbd = event.target.querySelector('kbd')
    if (!kbd) return

    event.preventDefault()
    kbd.classList.add('kbd--called')
    requestAnimationFrame(() => event.target.click())
  })

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
