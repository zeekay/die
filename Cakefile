{exec} = require './src/utils'

task 'build', 'compile src/*.coffee to lib/*.js', ->
  console.log 'Compiling src/*.coffee to lib/*.js'
  exec './node_modules/.bin/coffee -bc -o lib/ src/'

task 'gh-pages', 'Publish docs to gh-pages', ->
  brief = require('brief')
    quiet: false
  brief.updateGithubPages()

task 'test', 'Run tests', ->
  exec './node_modules/.bin/mocha ./test --compilers coffee:coffee-script -R spec -t 5000 -c'

task 'publish', 'publish current version to NPM', ->
  exec [
    './node_modules/.bin/coffee -bc -o lib/ src/'
    'git push'
    'npm publish'
  ]
