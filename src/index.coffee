Die = require './die'

die = new Die

wrapper = (cb) ->
  app = die.createServer()
  if cb and cb.call
    cb.call app
  app

for key, val of die
  wrapper[key] = val

wrapper.version = require('../package.json').version
wrapper.test = require './test'
module.exports = wrapper
