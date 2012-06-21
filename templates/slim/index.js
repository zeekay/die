die = require('die')({
  base: __dirname
});

app = die.createServer();

if (!module.parent) {
  app.run();
} else {
  module.exports = app;
}
