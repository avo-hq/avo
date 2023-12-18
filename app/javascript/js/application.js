import 'mapkick/bundle'

import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import TurboPower from 'turbo_power'

console.log('Turbo.StreamActions->', Turbo.StreamActions)

TurboPower.initialize(Turbo.StreamActions)

const application = Application.start()

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)

export { application }
