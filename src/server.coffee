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
    app.use express.logger()
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

  app.configure 'production', ->
    app.use express.errorHandler()

  # serve CSS bundle
  if opts.cssBundle and existsSync dirname opts.cssBundle.entry
    cssBundle = require('./bundle').createCssBundler opts.cssBundle, opts.base
    app.get opts.cssBundle.url, (req, res) ->
      res.header 'Content-Type', 'text/css'
      try
        res.send cssBundle.compile()
      catch err
        console.error "Error bundling CSS: #{err.toString().substring 7}"
      return

  # serve JavaScript bundle
  if opts.jsBundle and existsSync dirname opts.jsBundle.entry
    jsBundle = require('./bundle').createJsBundler opts.jsBundle, opts.base
    app.get opts.jsBundle.url, (req, res) ->
      res.header 'Content-Type', 'application/javascript'
      jsBundle.bundle (err, content) ->
        if err
          console.error "Error bundling JavaScript: #{err.toString().substring 7}"
        else
          res.send content

  app.extend = (func) ->
    if typeof func is 'function'
      exports.extend app, func
    else
      throw new Error "Function required for extend"
    app

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

  # Shortcut to add routes out of a folder
  app.addRoutes = (routes) ->
    if not Array.isArray routes
      routes = [routes]

    # for route in routes
      exports.extend app, route

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

  func.call app

  # put things back in case someone else wants to interact with the express app we create normally
  for verb in ['get', 'post', 'put', 'del']
    delete app[verb]
    delete app["__orig_#{verb}"]
