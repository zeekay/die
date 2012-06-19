build     = require './build'
compilers = require './compilers'
config    = require './config'
pkg       = require './package'
server    = require './server'

class Die
  constructor: (options = {}) ->
    for key, val of options
      @options[key] = val
    @readConfig()

  options: config.defaults

  build: ->
    @readConfig 'production'
    build @

  compilers: compilers

  createServer: -> server @

  cssPackage: ->
    pkg.createCss @options.css

  jsPackage: ->
    pkg.createJs
      dependencies: @options.dependencies
      paths: @options.paths
      libs: @options.libs

  readConfig: (name) ->
    @options = config.readConfig @options, name

module.exports = Die
