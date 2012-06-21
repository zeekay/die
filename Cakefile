{exec} = require './src/utils'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  console.log 'Compiling src/*.coffee to lib/*.js'
  exec.serial [
    'coffee -bc -o lib/ src/'
    'git add lib'
  ]


task 'publish', 'publish current version to NPM', ->
  invoke 'build'
  exec.serial [
    ['git', 'commit', 'lib', '-m', '"Compiled lib/*"']
    'npm version patch'
    'git push'
    'npm publish'
  ]
