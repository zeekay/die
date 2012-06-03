config    = require './config'
compilers = require './compilers'
defaults  = require './defaults'
create    = require './create'
{exec}    = require './cli'
server    = require './server'
Hem       = require 'hem'

class Hemlock extends Hem
  constructor: (options = {}) ->
    @options[key] = value for key, value of options
    config.readConfig.call @

  options: defaults

  create: ->
    create.call @
  server: ->
    server.runServer.call @
  createServer: ->
    server.createServer.call @
  readConfig: ->
    config.readConfig.call @
  exec: ->
    exec.call @

for key, val of compilers
  Hemlock::compilers[key] = val

hemlock = new Hemlock
hemlock.Hemlock = Hemlock
module.exports = hemlock
