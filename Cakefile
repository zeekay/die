{exec} = require 'child_process'

run = (cmd, callback) ->
  exec cmd, (err, stderr, stdout) ->
    if stderr
      console.error stderr.trim()
    if stdout
      console.log stdout.trim()

    if typeof callback == 'function'
      callback err, stderr, stdout

task 'build', 'compile src/*.coffee to lib/*.js', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/'

task 'gh-pages', 'Publish docs to gh-pages', ->
  brief = require 'brief'
  brief()

task 'test', 'Run tests', ->
  run './node_modules/.bin/mocha ./test --compilers coffee:coffee-script -R spec -t 5000 -c'

task 'publish', 'Publish project', ->
  run './node_modules/.bin/coffee -bc -o lib/ src/', ->
    run 'git push', ->
      run 'npm publish', ->
        invoke 'gh-pages'
