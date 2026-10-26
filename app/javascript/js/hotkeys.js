/**
 * Matches keydown events against the bindings Avo resolves on the server (config.hotkeys[:bindings]).
 * Used by every listener that can't hand its key to @github/hotkey's data-hotkey, so overrides,
 * aliases ("j,ArrowDown") and sequences ("g i") work the same way there.
 */

import { SequenceTracker, eventToHotkeyString, normalizeHotkey } from '@github/hotkey'

const MODIFIER_KEYS = ['Control', 'Alt', 'Meta', 'Shift']

// Shifted punctuation depends on the layout: some browsers report Shift+/ as key "/" instead of "?".
// Matching the physical key too keeps the "?" and "Shift+|" defaults working on non-US keyboards.
const SHIFTED_CODES = { Slash: '?', Backslash: '|' }

const tracker = new SequenceTracker()

// Capture phase on document runs before every bubbling listener, so they all see the current key.
document.addEventListener('keydown', (event) => {
  if (event.repeat || MODIFIER_KEYS.includes(event.key)) return

  tracker.registerKeypress(event)
}, true)

export function keyFor(id) {
  return window.Avo?.configuration?.hotkeys?.bindings?.[id] ?? null
}

// Same alias splitting as @github/hotkey: a comma right after a key separates aliases.
function parse(hotkey) {
  const aliases = []
  let chords = ['']
  let commaIsSeparator = false

  for (const char of hotkey) {
    if (commaIsSeparator && char === ',') {
      aliases.push(chords)
      chords = ['']
      commaIsSeparator = false
    } else if (char === ' ') {
      chords.push('')
      commaIsSeparator = false
    } else {
      commaIsSeparator = char !== '+'
      chords[chords.length - 1] += char
    }
  }
  aliases.push(chords)

  return aliases.map((list) => list.filter(Boolean).map((chord) => normalizeHotkey(chord))).filter((list) => list.length)
}

function currentChords(event) {
  const chords = [eventToHotkeyString(event)]
  const shifted = SHIFTED_CODES[event.code]
  if (event.shiftKey && shifted) chords.push(eventToHotkeyString({ ...modifiersOf(event), key: shifted }))

  // On a non-Latin layout (Cyrillic, Greek...) the J key reports "о", so fall back to the physical letter.
  const letter = event.code?.match(/^Key([A-Z])$/)?.[1]
  if (letter && !/^[\x20-\x7e]$/.test(event.key)) {
    chords.push(eventToHotkeyString({ ...modifiersOf(event), key: event.shiftKey ? letter : letter.toLowerCase() }))
  }

  return chords
}

function modifiersOf({ ctrlKey, altKey, metaKey, shiftKey }) {
  return { ctrlKey, altKey, metaKey, shiftKey }
}

export function matchesHotkey(event, hotkey) {
  if (!hotkey) return false

  const path = tracker.path
  const chords = currentChords(event)

  return parse(hotkey).some((sequence) => {
    const last = sequence[sequence.length - 1]
    if (!chords.includes(last)) return false
    if (sequence.length === 1) return true

    // The tracker already holds this keypress (recorded in the capture phase), so compare what came before it.
    const previous = path.slice(-sequence.length, -1)

    return previous.length === sequence.length - 1 && previous.every((chord, index) => chord === sequence[index])
  })
}

export function matches(event, id) {
  return matchesHotkey(event, keyFor(id))
}

window.Avo = window.Avo || { configuration: {} }
window.Avo.hotkeys = { keyFor, matches, matchesHotkey }
