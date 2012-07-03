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
    # Extra paths to search for modules
    modulePaths: []
    # Bundle creation function, should return a compiler
    # which will be used by the bundle middleware
    create: require('./bundle').createJsBundle

  # bundled CSS
  cssBundle:
    # entry point for css
    entry: './client/css/app'
    # url to server CSS bundle from
    url: '/app.css'
    # Extra functions for stylus
    functions: {}
    # Extra paths for stylus to include
    include: []
    # Extra plugins for stylus to use
    plugins: []
    # Bundle creation function, should return a compiler
    # which will be used by the bundle middleware
    create: require('./bundle').createCssBundle
