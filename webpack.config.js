var path = require('path');

module.exports = {
  entry: './lib/client/index.js',
  output: {
    path: path.join(__dirname, 'webclient'),
    filename: 'share.js'
  },
  module: {
    loaders: [
      { test: /\.json$/, loader: 'json' }
    ]
  }
};
