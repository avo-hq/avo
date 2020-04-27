const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')

const aliases = require('./aliases')
const vue = require('./loaders/vue')
const vueSvg = require('./loaders/vue-svg')

environment.loaders.append('vueSvg', vueSvg)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.append('vue', vue)
environment.config.merge(aliases)
module.exports = environment
