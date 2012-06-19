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

  build: ->
    src = @options.public or '.'
    dest = @options.dist or 'dist/'

    # copy template to dest
    wrench.copyDirSyncRecursive src, dest

    source = @hemPackage().compile(not argv.debug)
    fs.writeFileSync path.join(dest, @options.jsPath), source

    source = @cssPackage().compile()
    fs.writeFileSync path.join(dest, @options.cssPath), source

for key, val of compilers
  Die::compilers[key] = val

die = new Die

wrapper = (cb) ->
  die.run cb

for key, val of die
  wrapper[key] = val

module.exports = wrapper
