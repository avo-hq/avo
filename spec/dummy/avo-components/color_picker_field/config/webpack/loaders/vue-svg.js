const { environment } = require('@rails/webpacker')

environment.loaders.get('file').test = /(.jpg|.jpeg|.png|.gif|.tiff|.ico|.eot|.otf|.ttf|.woff|.woff2)$/i
const svgFileLoaderOptions = environment.loaders.get('file').use.find((loader) => loader.loader === 'file-loader').options

module.exports = {
  test: /\.svg$/,
  oneOf: [
    {
      resourceQuery: /inline/,
      use: [
        'babel-loader',
        'vue-svg-loader',
      ],
    },
    {
      loader: 'file-loader',
      options: svgFileLoaderOptions,
    },
  ],
}
