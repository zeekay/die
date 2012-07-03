Die = require './die'
{basename} = require 'path'
{readdirSync} = require 'fs'

# Create wrapper function which will return new Die instances.
wrapper = (opts) ->
  new Die opts

wrapper.Die = Die
wrapper.run = -> wrapper().run()

# Lazily export other modules
for mod in readdirSync __dirname
  if not (/index|die|wrapper/.test mod)
    do (mod) ->
      name = basename(mod).split('.')[0]
      console.log name
      Object.defineProperty wrapper, name,
        get: -> require mod
        enumerable: true

# Borrow version information from `package.json`.
Object.defineProperty wrapper, 'version',
  get: -> require('../package.json').version
  enumerable: true

module.exports = wrapper
