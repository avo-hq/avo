import flatpickr from 'flatpickr'

import nearestTopLayer from './top_layer'

// Flatpickr appends its calendar to <body>, so a calendar opened from inside a
// top-layer modal renders underneath it (see ./top_layer for the why).
//
// Importing this module installs the fix as a flatpickr default, so every
// picker in the app (date fields, filters, anything added later) cooperates
// with top-layer modals automatically — there's nothing to remember per field.
// When the input lives inside a popover/dialog we move the calendar into that
// top-layer element so it shares the layer, then correct flatpickr's
// positioning for the popover's fixed, viewport-anchored containing block.

function moveCalendarIntoTopLayer(selectedDates, dateStr, instance) {
  const topLayer = nearestTopLayer(instance.element)

  if (topLayer) topLayer.appendChild(instance.calendarContainer)
}

function repositionInTopLayer(selectedDates, dateStr, instance) {
  if (!nearestTopLayer(instance.element)) return

  // Flatpickr positions the calendar *after* onOpen, in document coordinates:
  // the input's viewport position plus the page's scroll offset. Inside a fixed
  // popover the containing block is the viewport itself (the modal locks body
  // scroll but keeps pageYOffset), so we wait for that positioning to land, then
  // strip the scroll offset back out. requestAnimationFrame runs after
  // flatpickr's synchronous positioning but before the next paint, so the
  // calendar never visibly jumps.
  requestAnimationFrame(() => {
    const { calendarContainer } = instance

    if (calendarContainer.style.top && calendarContainer.style.top !== 'auto') {
      calendarContainer.style.top = `${parseFloat(calendarContainer.style.top) - window.pageYOffset}px`
    }
    if (calendarContainer.style.left && calendarContainer.style.left !== 'auto') {
      calendarContainer.style.left = `${parseFloat(calendarContainer.style.left) - window.pageXOffset}px`
    }
  })
}

flatpickr.setDefaults({
  onReady: [moveCalendarIntoTopLayer],
  onOpen: [repositionInTopLayer],
})
