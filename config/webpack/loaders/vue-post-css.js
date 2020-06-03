module.exports = {
  test: /\.css$/,
  use: [
    'vue-style-loader',
    {
      loader: 'css-loader',
      options: { importLoaders: 1 },
    },
    'postcss-loader',
    // {
    //   loader: 'postcss-loader',
    //   options: {
    //     ident: 'postcss',
    //     config: {
    //       path: path.resolve(__dirname, '..', '..', '..'),
    //     },
    //   },
    // },
  ],
}
