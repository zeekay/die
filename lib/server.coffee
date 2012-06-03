child        = require 'child_process'
express      = require 'express'
path         = require 'path'

createServer = ->
  app = express.createServer()

  @readConfig app.settings.env

  app.configure =>
    app.set 'port', @options.port

    if path.existsSync @options.public
      app.use express.static @options.public

  app.configure 'test', =>
    app.set 'port', @options.port + 1

  app.configure 'development', ->
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

  app.configure 'production', ->
    app.use express.errorHandler()

  app.get @options.cssPath, (req, res) =>
    res.header 'Content-Type', 'text/css'
    res.send @cssPackage().compile()

  app.get @options.jsPath, (req, res) =>
    res.header 'Content-Type', 'application/javascript'
    res.send @hemPackage().compile()

  app.run = (cb) ->
    app.listen app.settings.port, ->
      console.log "up & running @ http://localhost:#{app.settings.port}"
      if cb
        cb()
    app

  app

runServer = ->
  app = createServer.call @
  app.run ->
    if process.platform == 'darwin'
      child.exec "open http://localhost:#{app.settings.port}", -> return

module.exports =
  createServer: createServer
  runServer: runServer
