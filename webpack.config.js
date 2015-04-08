var path = require('path');

module.exports = {
  entry: './lib/client/index.js',
  output: {
    path: path.join(__dirname, 'webclient'),
    filename: 'share.js',
    libraryTarget: 'umd',
    library: 'sharejs'
  },
  module: {
    loaders: [
      { test: /\.json$/, loader: 'json' }
    ]
  }
};
