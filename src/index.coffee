Die = require './die'

wrapper = (opts) ->
  new Die opts

wrapper.Die = Die
wrapper.run = -> wrapper().run()
wrapper.build = -> wrapper().build()
wrapper.test = require './test'
wrapper.version = require('../package.json').version
module.exports = wrapper
