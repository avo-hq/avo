import '@/css/application.css'

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as Mousetrap from 'mousetrap';
import Avocado from '@/js/Avo'

document.addEventListener('DOMContentLoaded', Avocado.init);
document.addEventListener('turbolinks:load', Avocado.turbolinksLoad);

Mousetrap.bind('r r r', () => Turbolinks.visit(window.location.href));
// import '@/js/bootstrap'
// import '@/js/vue'

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
const svgs = require.context('../svgs', true)
const svgPath = (name) => svgs(name, true)

import '~/heroicons/dist/outline-md/md-adjustments.svg'

// Start turbolinks & UJS
if (!Turbolinks || !Turbolinks.controller || !Turbolinks.controller.started) Turbolinks.start();
if (!window._rails_loaded) Rails.start();
