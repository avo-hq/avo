// Native popovers and dialogs (e.g. Avo's action modal, dropdown menus) render
// in the browser's "top layer", which paints above everything in the normal
// layer regardless of z-index. Any floating UI a library appends to <body>
// (flatpickr calendars, Tagify dropdowns, tippy tooltips, ...) therefore renders
// *underneath* a modal it was opened from, and no z-index can lift it out.
//
// The fix for every such library is the same: append the floating element into
// the nearest top-layer ancestor instead of <body>, so it shares the layer.
// This is the single source of truth for "what counts as a top-layer ancestor".
export default function nearestTopLayer(element) {
  return element?.closest('[popover], dialog') ?? null
}
