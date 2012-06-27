bundle  = require './bundle'
config  = require './config'
express = require 'express'

path    = require 'path'
join    = path.join
dirname = path.dirname

existsSync = require './utils'

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

  # serve compiled CSS
  if opts.cssBundle
    dir = dirname join opts.base, opts.cssBundle.main
    if existsSync dir
      app.get opts.cssBundle.url, (req, res) =>
        css = bundle.css opts.cssBundle, opts.base
        res.header 'Content-Type', 'text/css'
        try
          res.send css.bundle()
        catch err
          console.error 'Error bundling CSS:'
          console.trace err
        return

  # serve compiled JS
  if opts.jsBundle
    dir = dirname join opts.base, opts.jsBundle.main
    if existsSync dir
      app.get opts.jsBundle.url, (req, res) ->
        js = bundle.js opts.jsBundle, opts.base
        res.header 'Content-Type', 'application/javascript'
        js.bundle (err, bundle) ->
          if err
            console.trace err
          else
            res.send bundle

  # run helper
  app.run = (func) ->
    app.listen opts.port, ->
      console.log "#{app.settings.env} server up and running at http://localhost:#{opts.port}"
      if typeof func is 'function'
        func()
    app
  app

# enables a zappa-ish DSL for configuring express apps
exports.extend = (app, func) ->
  if typeof func isnt 'function'
    return

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
