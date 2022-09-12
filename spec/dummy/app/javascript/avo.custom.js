import { Application } from '@hotwired/stimulus'
import CourseResourceController from './avo_custom/course_resource_controller'

// Use you own stimulus install
const application = Application.start()
// Or hook into the stimulus instance provided by Avo
// const application = window.Stimulus

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
application.register('course-resource', CourseResourceController)

// eslint-disable-next-line no-console
console.log('Hi from Avo custom JS 👋')
