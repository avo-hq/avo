import { Application } from '@hotwired/stimulus'
import { Alert, Popover } from 'tailwindcss-stimulus-components'
import ClipboardController from './controllers/clipboard_controller'
import PasswordVisibility from '@stimulus-components/password-visibility'
import TextareaAutogrow from 'stimulus-textarea-autogrow'
import TurboPower from 'turbo_power'

TurboPower.initialize(window.Turbo.StreamActions)

const application = Application.start()
application.register('textarea-autogrow', TextareaAutogrow)
application.register('password-visibility', PasswordVisibility)
application.register('clipboard', ClipboardController)

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)

export { application }
