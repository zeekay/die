require('coffee-script');
app = require('./app');

if (!module.parent) {
  app.run();
} else {
  module.exports = app;
}
