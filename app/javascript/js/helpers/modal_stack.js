// The open Avo modals, bottom to top. A belongs_to "Create new" dialog opens on top of the modal it
// was started from, so Escape, focus and hotkeys have to act on the topmost one only.
const stack = []

export function removeModal(modal) {
  const index = stack.indexOf(modal)
  if (index >= 0) stack.splice(index, 1)

  document.body.classList.toggle('modal-open', stack.length > 0)
}

export function pushModal(modal) {
  removeModal(modal)
  stack.push(modal)
  document.body.classList.add('modal-open')
}

export function topmostModal() {
  return stack.at(-1)
}

// True for an element inside an open modal that has another modal on top of it.
export function isUnderStackedModal(element) {
  const owner = stack.findLast((modal) => modal.contains(element))

  return Boolean(owner) && owner !== topmostModal()
}
