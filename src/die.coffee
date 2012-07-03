{extend, existsSync} = require './utils'
{join} = require 'path'

class Die

  # Export common middleware lazily
  for middleware in ['bodyParser', 'cookieParser', 'errorHandlerH', 'methodOverride', 'session']
    do (middleware) =>
      Object.defineProperty @, middleware,
        get: -> require('express')[middleware]

  # Lazy require server
  Object.defineProperty @::, 'server',
    get: -> require './server'

  constructor: (options = {}) ->
    @options = extend {}, require './defaults'
    @options = extend options, @options

    # Set base path for this app
    @base = @options.base = options.base or process.cwd()

    # Try to read default config
    @readConfig()

  readConfig: (config = 'default') ->
    try
      options = require join(@base, @options.configPath, config)
    catch err
      return

    @options = extend options, @options

  build: ->
    @readConfig 'production'
    require('./build')(@options)

  createServer: (func) ->
    @readConfig process.env.NODE_ENV or 'development'

    if not @app
      @app = @server.createServer @options
      if func
        @server.extend @app, func

    @app

  extend: (func) ->
    @createServer()
    @server.extend @app, func
    @

  inject: (dieApp) ->
    @createServer()
    @app.use dieApp.app

    if @options.cssBundle and dieApp.cssBundle
      css = @options.cssBundle
      # other = dieApp.options.cssBundle
      # for k,v of other.functions
      #   if not css.functions[k]
      #     css.functions[k] = v
      # cssPath = dirname join dieApp.base, other.entry
      # css.include = css.include.concat cssPath, other.include
      # css.plugins = css.plugins.concat other.plugins

    if @options.jsBundle and dieApp.jsBundle
      js = @options.cssBundle
      # other = dieApp.options.jsBundle
      # js.modulePaths = js.modulePaths.concat other.modulePaths
    @

  mount: (url, dieApp) ->
    @createServer()
    @app.use url, dieApp.app
    @

  run: (func) ->
    @createServer func
    require('./run')(@app)

module.exports = Die
