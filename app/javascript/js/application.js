import { Alert, Popover } from 'tailwindcss-stimulus-components'
import { Application } from '@hotwired/stimulus'
import HwComboboxController from '@josefarias/hotwire_combobox'
import PasswordVisibility from '@stimulus-components/password-visibility'
import TextareaAutogrow from 'stimulus-textarea-autogrow'
import TurboPower from 'turbo_power'

TurboPower.initialize(window.Turbo.StreamActions)

const application = Application.start()
application.register('textarea-autogrow', TextareaAutogrow)
application.register('password-visibility', PasswordVisibility)

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Stimulus = application

// Register stimulus-components controller
application.register('alert', Alert)
application.register('popover', Popover)
application.register('hw-combobox', HwComboboxController)

export { application }
