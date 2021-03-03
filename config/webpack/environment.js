const { environment } = require('@rails/webpacker')

const aliases = require('./aliases')

environment.config.merge(aliases)
module.exports = environment
