Die = require './die'
{basename, join} = require 'path'
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
      Object.defineProperty wrapper, name,
        get: -> require join __dirname, mod
        enumerable: true

# Borrow version information from `package.json`.
Object.defineProperty wrapper, 'version',
  get: -> require('../package.json').version
  enumerable: true

module.exports = wrapper
