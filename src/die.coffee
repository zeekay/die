build  = require './build'
config = require './config'
server = require './server'

class Die
  constructor: (options = {}) ->
    for key, val of options
      @options[key] = val
    @options.base = options.base or process.cwd()
    @options = config.read @options, 'default'

  options: config.defaults

  build: ->
    @options = config.read @options, 'production'
    build @options

  createServer: (func) ->
    app = server.createServer @options
    server.extend app, func
    app

  run: (func) ->
    app = @createServer func
    app.run()

module.exports = Die
