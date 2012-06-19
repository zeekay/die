config    = require './config'
compilers = require './compilers'
defaults  = require './defaults'
create    = require './create'
cli       = require './cli'
server    = require './server'
pkg       = require './package'
test      = require './test'
Hem       = require 'hem'

class Die extends Hem
  constructor: (options = {}) ->
    @options[key] = value for key, value of options
    config.readConfig.call @

  options: defaults

  exec: ->
    cli.exec.call @

  new: ->
    create()

  server: ->
    server.runServer.call @

  createServer: ->
    server.createServer.call @

  readConfig: ->
    config.readConfig.call @

  hemPackage: ->
    pkg.createPackage
      dependencies: @options.dependencies
      paths: @options.paths
      libs: @options.libs

  test: (args) -> test args

  run: (cb) ->
    app = server.createServer.call die, cb
    app.run()

for key, val of compilers
  Die::compilers[key] = val

die = new Die

wrapper = (cb) ->
  die.run cb

for key, val of die
  wrapper[key] = val

module.exports = wrapper
