const { environment } = require('@rails/webpacker')
const aliases = require('./aliases')

environment.config.merge(aliases)

// Fix the post-css loader config format
environment.loaders.keys().forEach(loaderName => {
  let loader = environment.loaders.get(loaderName);
  loader.use.forEach(loaderConfig => {
    if (loaderConfig.options && loaderConfig.options.config) {
      loaderConfig.options.postcssOptions = loaderConfig.options.config;
      delete loaderConfig.options.config;
    }
  });
});


module.exports = environment
