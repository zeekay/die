module.exports =
  # path to configuration files
  configPath: './config'

  # path to compile assets to
  buildPath: './dist'

  # path to static files
  staticPath: './public'

  # port to run from
  port: process.env.PORT or 3000

  # bundles are served by the bundle middleware
  bundles:
    # url to serve javascript from
    '/app.js':
      # entry point for javascript
      main: './assets/js/app'
      # scripts to include before/after bundled Javascript
      before: []
      after: []
      # Extra paths to search for modules
      modulePaths: []

    # url to server CSS bundle from
    '/app.css':
      # entry point for css
      main: './assets/css/app'
      # Extra functions for stylus
      functions: {}
      # Extra paths for stylus to include
      include: []
      # Extra plugins for stylus to use
      plugins: []
