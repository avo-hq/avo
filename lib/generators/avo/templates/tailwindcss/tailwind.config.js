const avoPreset = require('../../tmp/avo/tailwind.preset.js')

module.exports = {
  presets: [avoPreset],
  content: [
    ...avoPreset.content,
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
  ]
}
