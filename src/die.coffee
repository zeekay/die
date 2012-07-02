config = require './config'

class Die
  constructor: (options = {}) ->
    for key, val of options
      @options[key] = val
    @options.base = options.base or process.cwd()
    @options = config.read @options, 'default'

  options: config.defaults

  build: ->
    @options = config.read @options, 'production'
    require('./build')(@options)

  createServer: (func) ->
    if not @app
      console.log 'called createServer'
      @app = require('./server').createServer @options
      if func
        @app.extend func

      # Expose common express middleware
      express = require 'express'
      @bodyParser = ->
        express.bodyParser.call express, arguments
      @cookieParser = ->
        express.cookieParser.call express, arguments
      @session = ->
        express.session.call express, arguments
      @methodOverride = ->
        express.methodOverride.call express, arguments
      @errorHandler = ->
        express.errorHandler.call express, arguments
    @app

  extend: (func) ->
    @createServer()
    @app.extend func
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
