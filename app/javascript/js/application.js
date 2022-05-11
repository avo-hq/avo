import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'

const application = Application.start()

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)

export { application }
