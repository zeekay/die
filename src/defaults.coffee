module.exports =
  # path to configuration files
  configPath: './config'

  # path to compile assets to
  buildPath: './dist'

  # path to static files
  staticPath: './public'

  # port to run from
  port: process.env.PORT or 3000

  # bundled JavaScript
  jsBundle:
    # entry point for javascript
    entry: './client/js/app'
    # url to serve javascript from
    url: '/app.js'
    # scripts to include before/after bundled Javascript
    before: []
    after: []

  # bundled CSS
  cssBundle:
    # entry point for css
    entry: './client/css/app'
    # url to server CSS bundle from
    url: '/app.css'
