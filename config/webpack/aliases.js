const path = require('path')

module.exports = {
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '..', '..', 'app/frontend'),
      '~': path.resolve(__dirname, '..', '..', 'node_modules')
    }
  }
}
