var die = require('die')({
  base: __dirname
});

var app = die.createServer();

if (!module.parent) {
  app.run();
} else {
  module.exports = app;
}
