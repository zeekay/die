module.exports =
  # path to configuration files
  configPath: '/config'

  # path to compile assets to
  buildPath: '/dist'

  # path to static files
  staticPath: '/public'

  # port to run from
  port: process.env.PORT or 3000

  # bundled JavaScript
  js:
    # entry point for javascript
    main: '/client/js/app'
    # url to serve javascript from
    url: '/app.js'
    # libraries to prepend before bundled JavaScript
    libs: []

  # bundled CSS
  css:
    main: '/client/css/app'
    url: '/app.css'
