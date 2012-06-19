build     = require './build'
cli       = require './cli'
compilers = require './compilers'
config    = require './config'
create    = require './create'
defaults  = require './defaults'
pkg       = require './package'
server    = require './server'
test      = require './test'
Hem       = require 'hem'

class Die extends Hem
  constructor: (options = {}) ->
    @options[key] = value for key, value of options
    config.readConfig.call @

  options: defaults

  exec: -> cli.exec.call @

  build: -> build.call @

  createServer: -> server.createServer.call @

  hemPackage: ->
    pkg.createPackage
      dependencies: @options.dependencies
      paths: @options.paths
      libs: @options.libs

  new: -> create()

  readConfig: -> config.readConfig.call @

  run: (cb) ->
    app = server.createServer.call die, cb
    app.run()

  test: (args) -> test args

for key, val of compilers
  Die::compilers[key] = val

die = new Die

wrapper = (cb) ->
  die.run cb

for key, val of die
  wrapper[key] = val

module.exports = wrapper
