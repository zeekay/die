express = require 'express'
path    = require 'path'

exports.createServer = (die) ->
  app = express.createServer()

  # read configuration based on NODE_ENV
  die.readConfig app.settings.env

  app.configure =>
    app.set 'port', die.options.port

    # setup views
    viewDir = path.join die.base, '/views'
    if path.existsSync viewDir
      app.set 'views', viewDir
      # use jade by default
      app.set 'view engine', 'jade'

    # setup static file serving
    publicDir = path.join die.base, die.options.public
    if path.existsSync publicDir
      app.use express.static publicDir
    else
      # serve cwd if public dir doesn't exist.
      app.use express.static die.base

  app.configure 'test', ->
    # listen on a different port when running tests
    app.set 'port', die.options.port + 1

  app.configure 'development', ->
    app.use express.logger()
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

  app.configure 'production', ->
    app.use express.errorHandler()

  # serve compiled CSS
  if die.options.cssPath
    app.get die.options.cssPath, (req, res) =>
      res.header 'Content-Type', 'text/css'
      try
        res.send die.cssPackage().compile()
      catch err
        console.error 'CSS packaging error:', err

  # serve compiled JS
  if die.options.jsPath
    app.get die.options.jsPath, (req, res) =>
      res.header 'Content-Type', 'application/javascript'
      try
        res.send die.jsPackage().compile()
      catch err
        console.error 'JavaScript packaging error:', err

  # run helper
  app.run = (func) ->
    app.listen app.settings.port, ->
      console.log "#{app.settings.env} server up and running at http://localhost:#{app.address().port}"
      if typeof func is 'function'
        func()
    app
  app

# enables a zappa-ish DSL for configuring express apps
exports.enableDsl = (app, func) ->
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
            request: req
            response: res
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
    app[verb] = app["__orig_#{verb}"]
