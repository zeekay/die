{exec} = require './src/utils'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  console.log 'Compiling src/*.coffee to lib/*.js'
  exec 'coffee -bc -o lib/ src/'

task 'publish', 'publish current version to NPM', ->
  invoke 'build'
  exec ['git', 'commit', '-a', '-m', 'Recompile lib/*']
  exec 'git push'
  exec 'npm version patch'
  exec 'npm publish'
