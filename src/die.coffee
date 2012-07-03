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

  defaultServer: ->
    @readConfig process.env.NODE_ENV or 'development'
    @createServer @server.default @options

  createServer: (func) ->
    @app = @server.createServer func
    @

  extend: (func) ->
    @defaultServer() if not @app
    @server.extend @app, func
    @

  inject: (dieApp) ->
    @defaultServer() if not @app
    @app.use dieApp.app
    @apps.push dieApp
    @

  mount: (url, dieApp) ->
    @defaultServer() if not @app
    @app.use url, dieApp.app
    @apps.push dieApp
    @

  run: (opts = @options) ->
    @defaultServer() if not @app
    require('./run')(@app, opts)

module.exports = Die
