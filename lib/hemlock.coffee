config    = require './config'
compilers = require './compilers'
defaults  = require './defaults'
create    = require './create'
cli       = require './cli'
server    = require './server'
Hem       = require 'hem'

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

for key, val of compilers
  Hemlock::compilers[key] = val

hemlock = new Hemlock

wrapper = (cb) ->
  server.createServer.call hemlock, cb

for key, val of hemlock
  wrapper[key] = val

module.exports = wrapper
