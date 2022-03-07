import { Application } from '@hotwired/stimulus'
import { Popover } from 'tailwindcss-stimulus-components'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

// Register stimulus-components controller
application.register('popover', Popover)

export { application }
