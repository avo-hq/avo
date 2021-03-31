const { webpackConfig, merge } = require('@rails/webpacker')
const aliases = require('./aliases')

const customConfig = {
  resolve: {
    extensions: ['.css'],
  },
}

const config = merge(webpackConfig, aliases, customConfig)

delete config.optimization

module.exports = config
