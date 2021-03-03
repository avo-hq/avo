const { environment } = require('@rails/webpacker')
const aliases = require('./aliases')

environment.config.merge(aliases)

environment.loaders
  .map((rule) => rule.value.use)
  .flat()
  .filter(({ loader }) => loader === 'postcss-loader')
  .forEach((item) => {
    if (item.options) {
      item.options.postcssOptions = { from: item.options.config.path }
      delete item.options.config
    }
  })

module.exports = environment
