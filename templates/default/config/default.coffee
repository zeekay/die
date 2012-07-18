module.exports =
  # path to compile assets to
  buildPath: './dist'

  # path to static files
  staticPath: './public'

  # port to run from
  port: process.env.PORT or 3000

  # bundled CSS
  cssBundle:
    entry: './assets/css/app'
    url: '/app.css'

  # bundled JavaScript
  jsBundle:
    # entry point for javascript
    entry: './assets/js/app'
    # url to serve javascript from
    url: '/app.js'
    # libraries to prepend before bundled JavaScript
    before: [
      './assets/vendor/jquery-1.7.2.min.js'
      './assets/vendor/bootstrap-alert.js'
      './assets/vendor/bootstrap-button.js'
      './assets/vendor/bootstrap-carousel.js'
      './assets/vendor/bootstrap-collapse.js'
      './assets/vendor/bootstrap-dropdown.js'
      './assets/vendor/bootstrap-modal.js'
      './assets/vendor/bootstrap-scrollspy.js'
      './assets/vendor/bootstrap-tab.js'
      './assets/vendor/bootstrap-tooltip.js'
      './assets/vendor/bootstrap-transition.js'
      './assets/vendor/bootstrap-typeahead.js'
    ]
