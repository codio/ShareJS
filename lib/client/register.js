var types = require('ottypes');

exports.registerType = function(type) {
  if (type.name) types[type.name] = type;
  if (type.uri) types[type.uri] = type;
};
