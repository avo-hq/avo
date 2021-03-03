import '@/css/application.css'

// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime'
import 'trix'
import '~/trix/dist/trix.css'
import * as Mousetrap from 'mousetrap'
import { Application } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import Avo from '@/js/Avo'
import Rails from '@rails/ujs'
import tippy from 'tippy.js'

// Toastr alerts
import '../js/toastr'

Rails.start()

Mousetrap.bind('r r r', () => Turbo.visit(window.location.href))

const application = Application.start()

const context = require.context('./../js/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

const fieldsContext = require.context('./../js/controllers/fields', true, /\.js$/)
application.load(definitionsFromContext(fieldsContext))

document.addEventListener('DOMContentLoaded', Avo.init)
document.addEventListener('turbo:load', () => {
  document.body.classList.remove('turbo-loading')

  tippy('[data-tippy="tooltip"]', {
    theme: 'light',
    content(reference) {
      const title = reference.getAttribute('title')
      reference.removeAttribute('title')

      return title
    },
  })
})
document.addEventListener('turbo:visit', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))

// Mousetrap.bind('r r r', () => Avo.reload())

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
const svgs = require.context('../svgs', true)
const svgPath = (name) => svgs(name, true)
