module.exports =
  # path to compile assets to
  buildPath: './dist'

  # path to static files
  staticPath: './public'

  # port to run from
  port: process.env.PORT or 3000

  # bundled CSS
  cssBundle:
    entry: './client/css/app'
    url: '/app.css'

  # bundled JavaScript
  jsBundle:
    # entry point for javascript
    entry: './client/js/app'
    # url to serve javascript from
    url: '/app.js'
    # libraries to prepend before bundled JavaScript
    before: [
      './vendor/jquery-1.7.2.min.js'
      './vendor/bootstrap-alert.js'
      './vendor/bootstrap-button.js'
      './vendor/bootstrap-carousel.js'
      './vendor/bootstrap-collapse.js'
      './vendor/bootstrap-dropdown.js'
      './vendor/bootstrap-modal.js'
      './vendor/bootstrap-scrollspy.js'
      './vendor/bootstrap-tab.js'
      './vendor/bootstrap-tooltip.js'
      './vendor/bootstrap-transition.js'
      './vendor/bootstrap-typeahead.js'
    ]
