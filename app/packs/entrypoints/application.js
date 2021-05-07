// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime'
import * as Mousetrap from 'mousetrap'
import { Application } from 'stimulus'
import { Turbo } from '@hotwired/turbo-rails'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import Rails from '@rails/ujs'
import tippy from 'tippy.js'

// Toastr alerts
import '../js/toastr'

Rails.start()

window.Turbolinks = Turbo

Mousetrap.bind('r r r', () => Turbo.visit(window.location.href, { action: 'replace' }))

function initTippy() {
  tippy('[data-tippy="tooltip"]', {
    theme: 'light',
    content(reference) {
      const title = reference.getAttribute('title')
      reference.removeAttribute('title')

      return title
    },
  })
}
window.initTippy = initTippy

const application = Application.start()

const context = require.context('./../js/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

const fieldsContext = require.context('./../js/controllers/fields', true, /\.js$/)
application.load(definitionsFromContext(fieldsContext))

document.addEventListener('turbo:load', () => {
  document.body.classList.remove('turbo-loading')
  initTippy()
})
document.addEventListener('turbo:visit', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('[data-turbo-remove-before-cache]').forEach((element) => element.remove())
})

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
