import { Application } from '@hotwired/stimulus'
import CourseResourceController from './avo_custom/course_resource_controller'

// const application = Application.start()
console.log('window.Stimulus->', window.Stimulus)
const application = window.Stimulus

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
application.register('course-resource', CourseResourceController)

// eslint-disable-next-line no-console
console.log('Hi from Avo custom JS 👋')
