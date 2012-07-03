Die = require './die'

# Create wrapper function which will return new Die instances.
wrapper = (opts) ->
  new Die opts

wrapper.Die = Die
wrapper.run = -> wrapper().run()

# Lazily export other modules
for mod in ['./build', './cli', './test']
  do (mod) ->
    Object.defineProperty wrapper, mod.substring(2),
      get: -> require mod
      enumerable: true

# Borrow version information from `package.json`.
Object.defineProperty wrapper, 'version',
  get: -> require('../package.json').version
  enumerable: true

module.exports = wrapper
