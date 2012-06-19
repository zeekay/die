var app = require('die')({
  basePath: __dirname
});

if (!module.parent) {
  app.run();
} else {
  module.exports = app.createServer();
}
