server = require './server'
{extend, existsSync} = require './utils'
{join} = require 'path'

class Die
  apps: []
  constructor: (options = {}) ->
    # Clone default options
    @options = extend {}, require './defaults'
    @options = extend options, @options

    # Set base path for this app
    @base = @options.base = options.base or process.cwd()

    # Update options using appropriate config files
    @updateOptions 'default'
    @updateOptions process.env.NODE_ENV or 'development'

    # Lazily create default app
    Object.defineProperty @, 'app',
      configurable: true
      enumerable: true
      get: =>
        # Replace accessor with @app
        delete @app
        @app = @createServer server.default(@options)

  # update options using configuration file or object
  updateOptions: (options) ->
    if typeof options is 'string'
      try
        options = require join(@base, @options.configPath, options)
      catch err
        return @options
    @options = extend options, @options

  build: ->
    @updateOptions 'production'
    require('./build')(@options)

  createServer: (func) ->
    @app = server.createServer func

  extend: (func) ->
    require('./extend') @app, func
    @

  inject: (dieApp) ->
    @app.use dieApp.app
    @apps.push dieApp
    @

  mount: (url, dieApp) ->
    @app.use url, dieApp.app
    @apps.push dieApp
    @

  run: (opts = @options) ->
    port = opts.port or 3000
    @app.listen port
    console.log "die #{@app.settings.env} server up and running at http://localhost:#{port}"

module.exports = Die
