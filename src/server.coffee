config  = require './config'
express = require 'express'

path    = require 'path'
join    = path.join
dirname = path.dirname

{existsSync} = require './utils'

exports.createServer = (opts) ->
  app = express.createServer()

  # read configuration based on NODE_ENV
  opts = config.read opts, app.settings.env

  app.configure ->
    app.set 'port', opts.port

    # setup views
    dir = join opts.base, '/views'
    if existsSync dir
      app.set 'views', dir
      # use jade by default
      app.set 'view engine', 'jade'

    # setup static file serving
    dir = join opts.base, opts.staticPath
    if existsSync dir
      app.use express.static dir
    else
      # serve cwd if public dir doesn't exist.
      app.use express.static opts.base

  app.configure 'test', ->
    # listen on a different port when running tests
    app.set 'port', opts.port + 1

  app.configure 'development', ->
    bundles = {}

    # css Bundles
    if opts.cssBundle and existsSync dirname opts.cssBundle.entry
      cssBundle = require('./bundle').createCssBundler opts.cssBundle, opts.base
      bundles['/app.css'] = (cb) ->
        try
          cb null, cssBundle.compile()
        catch err
          cb err, ''

    # js Bundles
    if opts.jsBundle and existsSync dirname opts.jsBundle.entry
      jsBundle = require('./bundle').createJsBundler opts.jsBundle, opts.base
      console.dir jsBundle
      bundles['/app.js'] = (cb) ->
        jsBundle.bundle (err, body) ->
          cb err, body

    app.use require('./middleware')(bundles)
    app.use express.logger()
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

  app.configure 'production', ->
    app.use express.errorHandler()

  # Return express app instance.
  app

# enables a zappa-ish DSL for configuring express apps
exports.extend = (app, func) ->

  # configuration shortcuts
  app.development = (func) ->
    app.configure 'development', ->
      func.call app

  app.production = (func) ->
    app.configure 'production', ->
      func.call app

  # setup specialized route handlers
  for verb in ['get', 'post', 'put', 'del']
    do (verb) ->
      # save a reference to original
      app["__orig_#{verb}"] = app[verb]

      app[verb] = (path, handler) ->
        app["__orig_#{verb}"] path, (req, res, next) ->
          ctx =
            app: app
            body: req.body
            next: next
            params: req.params
            query: req.query
            req: req
            res: res
            session: req.session
            settings: app.settings
            json: -> res.json.apply res, arguments
            redirect: -> res.redirect.apply res, arguments
            render: -> res.render.apply res, arguments
            send: -> res.send.apply res, arguments
          handler.apply ctx, req.params

  # Shortcut to add routes
  app.addRoutes = (routes) ->
    if not Array.isArray routes
      routes = [routes]

    for route in routes
      route.call app

  func.call app

  console.log app.stack

  # put things back in case someone else wants to interact with the express app we create normally
  for verb in ['get', 'post', 'put', 'del']
    delete app[verb]
    delete app["__orig_#{verb}"]
  delete app.development
  delete app.production
  delete app.addRoutes
