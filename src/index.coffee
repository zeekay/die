{existsSync} = require './utils'

# This is a bit of a hack, if `../src` exists then assume we're being required
# from the git repo. To make development a bit easier we'll require the
# uncompiled version of the project. In normal production use `../src` will
# be missing since it's in `.npmignore`.
if existsSync __dirname + '/../src'
  require 'coffee-script'
  Die  = require '../src/die'
  test = require '../src/test'
else
  Die = require './die'
  test = require './test'

# Create wrapper function which will return new Die instances.
wrapper = (opts) ->
  new Die opts

wrapper.Die = Die

# Helper functions.
wrapper.run = -> wrapper().run()
wrapper.build = -> wrapper().build()
wrapper.test = test

# Borrow version information from `package.json`.
wrapper.version = require('../package.json').version

module.exports = wrapper
