const application = window.Stimulus

// This is going run last so it can regiser custom StimulusJS controllers from plugins.
if (window.Avo.configuration.stimulus_controllers) {
  window.Avo.configuration.stimulus_controllers.forEach(([name, controller]) => {
    application.register(name, window[controller])
  })
}
