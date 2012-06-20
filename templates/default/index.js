var die = require('die')({
  basePath: __dirname
});

var app = die.createServer();

if (!module.parent) {
  app.run();
} else {
  module.exports = app;
}
