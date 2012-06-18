config    = require './config'
compilers = require './compilers'
defaults  = require './defaults'
create    = require './create'
cli       = require './cli'
server    = require './server'
pkg       = require './package'
Hem       = require 'hem'
{exec}    = require 'child_process'
path      = require 'path'

class Hemlock extends Hem
  constructor: (options = {}) ->
    @options[key] = value for key, value of options
    config.readConfig.call @

  options: defaults

  exec: ->
    cli.exec.call @

  create: ->
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

  test: (args = '--compilers coffee:coffee-script -R spec -t 5000 -c test/*') ->
    bin = 'node_modules/mocha/bin/mocha'
    if not path.existsSync bin
      bin = 'mocha'
    exec "#{bin} #{args}", (err, stdout, stderr) ->
      console.log stdout
      console.error stderr

for key, val of compilers
  Hemlock::compilers[key] = val

hemlock = new Hemlock

wrapper = (cb) ->
  server.createServer.call hemlock, cb

for key, val of hemlock
  wrapper[key] = val

module.exports = wrapper
