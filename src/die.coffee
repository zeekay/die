build     = require './build'
compilers = require './compilers'
config    = require './config'
pkg       = require './package'
server    = require './server'
{join}    = require 'path'

class Die
  constructor: (options = {}) ->
    for key, val of options
      @options[key] = val
    @base = options.base or process.cwd()
    @readConfig()

  options: config.defaults

  build: ->
    @readConfig 'production'
    build @

  compilers: compilers

  createServer: (func) ->
    app = server.createServer @
    server.enableDsl app, func
    app

  cssPackage: ->
    pkg.createCss join @base, @options.css

  jsPackage: ->
    pkg.createJs
      dependencies: (join @base, mod for mod in @options.dependencies)
      paths: (join @base, path for path in @options.paths)
      libs: (join @base, lib for lib in @options.libs)

  readConfig: (name = 'default') ->
    path = join @base, @options.configPath, name
    @options = config.readConfig @options, path

  run: (func) ->
    app = @createServer func
    app.run()

module.exports = Die
