import { Application } from '@hotwired/stimulus'
import CourseResourceController from './avo_custom/course_resource_controller'

const application = Application.start()

// Configure Stimulus development experience
application.debug = window?.localStorage.getItem('avo.debug')
application.register('course-resource', CourseResourceController)
