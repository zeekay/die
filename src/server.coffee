child   = require 'child_process'
express = require 'express'
path    = require 'path'

module.exports = (die) ->
  app = express.createServer()

  die.readConfig app.settings.env

  app.configure =>
    app.set 'port', die.options.port

    publicDir = path.join die.base, die.options.public
    if path.existsSync publicDir
      app.use express.static publicDir
    else
      app.use express.static die.base

  app.configure 'test', =>
    app.set 'port', die.options.port + 1

  app.configure 'development', ->
    app.use express.logger()
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

  app.configure 'production', ->
    app.use express.errorHandler()

  if die.options.cssPath
    app.get die.options.cssPath, (req, res) =>
      res.header 'Content-Type', 'text/css'
      res.send die.cssPackage().compile()

  if die.options.jsPath
    app.get die.options.jsPath, (req, res) =>
      res.header 'Content-Type', 'application/javascript'
      res.send die.jsPackage().compile()

  app.run = (cb) ->
    app.listen app.settings.port, ->
      console.log "#{app.settings.env} server up and running at http://localhost:#{app.address().port}"
      cb() if cb
    app

  app
