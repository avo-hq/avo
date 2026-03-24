/**
 * Shared rules for when global keyboard shortcuts should not run (user is typing).
 */

export const TYPING_FIELD_SELECTOR = 'input, textarea, select, [contenteditable], [contenteditable="true"]'

export function eventTargetIsTypingField(event) {
  const { target } = event
  if (!target || typeof target.closest !== 'function') return false

  return Boolean(target.closest(TYPING_FIELD_SELECTOR))
}
