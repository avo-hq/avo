import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'
import TextareaAutogrow from 'stimulus-textarea-autogrow'
import TurboPower from 'turbo_power'

TurboPower.initialize(window.Turbo.StreamActions)

const application = Application.start()
application.register('textarea-autogrow', TextareaAutogrow)

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)

export { application }
