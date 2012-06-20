{exec} = require 'child_process'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  exec 'coffee -bc -o lib/ src/'

task 'publish', 'publish current version to NPM', ->
  exec 'npm version minor'
