build     = require './build'
compilers = require './compilers'
config    = require './config'
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

  build: -> build @

  createServer: -> server.createServer.call @

  hemPackage: ->
    pkg.createPackage
      dependencies: @options.dependencies
      paths: @options.paths
      libs: @options.libs

  readConfig: -> config.readConfig.call @

  run: (cb) ->
    app = server.createServer.call die, cb
    app.run()

  test: (opts) -> test opts

for key, val of compilers
  Die::compilers[key] = val

die = new Die

wrapper = (cb) -> die.run cb

for key, val of die
  wrapper[key] = val

module.exports = wrapper
