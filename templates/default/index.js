require('coffee-script');
module.exports = app = require('./app');

if (!module.parent) app.run()
