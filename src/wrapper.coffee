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
  if not (/index|die|wrapper|worker/.test mod)
    do (mod) ->
      name = basename(mod).split('.')[0]
      Object.defineProperty wrapper, name,
        get: -> require join __dirname, mod
        enumerable: true

# Extra properties to export
extra =
  'version': '../package.json'
  # 'requireAll': './utils'

for property, mod of extra
  do (property, mod) ->
    Object.defineProperty wrapper, property,
      get: -> require(mod)[property]
      enumerable: true

module.exports = wrapper
