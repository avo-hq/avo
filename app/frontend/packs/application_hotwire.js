import '@/css/application.css'

import 'regenerator-runtime/runtime'
import * as Mousetrap from 'mousetrap'
import { Application } from 'stimulus'
import { Turbo, cable } from '@hotwired/turbo-rails'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import Avo from '@/js/hotwire/Avo'
import I18n from 'i18n-js'

Mousetrap.bind('r r r', () => Turbo.visit(window.location.href))

const application = Application.start()

const context = require.context('./../js/hotwire/controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

window.I18n = I18n

document.addEventListener('DOMContentLoaded', Avo.init)

// Mousetrap.bind('r r r', () => Avo.reload())

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
const svgs = require.context('../svgs', true)
const svgPath = (name) => svgs(name, true)
