build     = require './build'
compilers = require './compilers'
config    = require './config'
path      = require 'path'
pkg       = require './package'
server    = require './server'
test      = require './test'
Hem       = require 'hem'

class Die extends Hem
  constructor: (options = {}) ->
    for key, val of options
      @options[key] = val
    @readConfig()

  options: config.defaults

  build: ->
    @readConfig 'production'
    build @

  createServer: -> server @

  hemPackage: ->
    pkg.createPackage
      dependencies: @options.dependencies
      paths: @options.paths.concat [path.dirname @options.main]
      libs: @options.libs

  readConfig: (name) ->
    @options = config.readConfig @options, name

for key, val of compilers
  Die::compilers[key] = val

module.exports = Die
