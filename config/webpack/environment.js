const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')

const aliases = require('./aliases')
const vue = require('./loaders/vue')
const vueSvg = require('./loaders/vue-svg')
const typescript = require('./loaders/typescript')

environment.loaders.prepend('vueSvg', vueSvg)
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('typescript', typescript)
environment.loaders.prepend('vue', vue)
environment.config.merge(aliases)
module.exports = environment
