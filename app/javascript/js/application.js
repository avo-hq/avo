import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'
import TurboPower from 'turbo_power'
import HwComboboxController from "@josefarias/hotwire_combobox"

TurboPower.initialize(window.Turbo.StreamActions)

const application = Application.start()

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)
application.register('hw-combobox', HwComboboxController)

export { application }
