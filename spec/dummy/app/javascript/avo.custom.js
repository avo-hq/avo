import { Application } from '@hotwired/stimulus'
import CityInCountryController from './avo_custom/city_in_country_controller'
import NestedForm from 'stimulus-rails-nested-form'

// Use you own stimulus install
const application = Application.start()
// Or hook into the stimulus instance provided by Avo
// const application = window.Stimulus

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
window.Avo.registerController('city-in-country', CityInCountryController)
window.Avo.registerController('nested-form', NestedForm)

// window.Avo

// eslint-disable-next-line no-console
console.log('Hi from Avo custom JS 👋')
