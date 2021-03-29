const { webpackConfig, merge } = require('@rails/webpacker')
const aliases = require('./aliases')

module.exports = merge(webpackConfig, aliases)
