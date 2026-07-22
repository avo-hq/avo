// Dummy host-app override — exercises the ejectable avo-overrides.js path.
// Shadows the empty file Avo ships. Loaded after avo/application.js, so
// window.Stimulus is available here.
//
// Turbo-safe: this runs once, but the listener fires on every Turbo visit.
// Register Stimulus controllers or attach turbo:load listeners here — don't do
// one-shot DOM mutations, they won't survive navigation.
document.addEventListener("turbo:load", () => {
  console.log("[avo-overrides] host override loaded ✓")
})
