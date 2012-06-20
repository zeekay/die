var die = require('die')({
  basePath: __dirname
});

var app = new die.createServer();

if (!module.parent) {
  app.run();
} else {
  module.exports = app;
}
