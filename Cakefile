{exec} = require './src/utils'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  console.log 'Compiling src/*.coffee to lib/*.js'
  exec 'coffee -bc -o lib/ src/'

task 'gh-pages', 'Publish docs to gh-pages', ->
  brief = require('brief')
    quiet: false
  brief.updateGithubPages()

task 'publish', 'publish current version to NPM', ->
  invoke 'build'
  exec.serial [
    ['git', 'commit', 'lib', '-m', '"Compiled lib/*"']
    'npm version patch'
    'git push'
    'npm publish'
  ]
