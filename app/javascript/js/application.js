import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'
import Clipboard from '@stimulus-components/clipboard'
import PasswordVisibility from '@stimulus-components/password-visibility'
import TextareaAutogrow from 'stimulus-textarea-autogrow'
import TurboPower from 'turbo_power'

TurboPower.initialize(window.Turbo.StreamActions)

const application = Application.start()

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)
application.register('clipboard', Clipboard)
application.register('password-visibility', PasswordVisibility)
application.register('textarea-autogrow', TextareaAutogrow)

export { application }
