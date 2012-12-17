bootstrap = require 'die-bootstrap'

module.exports =
  # path to compile assets to
  buildPath: './dist'

  # path to static files
  staticPath: './public'

  # port to run from
  port: process.env.PORT or 3000

  bundles:
    # bundled css
    '/app.css':
      main: './assets/css/app'

    # bundled javascript
    '/app.js':
      main: './assets/js/app'
      before: [
        './assets/vendor/jquery-1.7.2.min.js'
      ]

    '/bootstrap.css':
      compiler: bootstrap.css
        responsive: true

    '/bootstrap.js':
      compiler: bootstrap.js
        only: [
          'popover'
          'typeahead'
        ]
