{exec} = require './src/utils'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  console.log 'Compiling src/*.coffee to lib/*.js'
  exec.serial [
    'coffee -bc -o lib/ src/'
    'git add lib'
    ['git', 'commit', 'lib', '-m', '"Compiled lib/*"']
  ]


task 'publish', 'publish current version to NPM', ->
  invoke 'build'
  exec.serial [
    'npm version patch'
    'git push'
    'npm publish'
  ]
