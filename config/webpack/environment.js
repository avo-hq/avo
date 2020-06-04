const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')

const aliases = require('./aliases')
const vue = require('./loaders/vue')
const vueSvg = require('./loaders/vue-svg')
// const vueCss = require('./loaders/vue-post-css')

environment.loaders.append('vueSvg', vueSvg)
environment.plugins.append('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.append('vue', vue)
// environment.loaders.append('vueCss', vueCss)
environment.config.merge(aliases)
module.exports = environment
