optimist = require 'optimist'
path     = require 'path'

argv = optimist.usage([
  ' Usage: die COMMAND'
  ''
  ' Commands:'
  '     build   assemble application'
  '     new     create a new project'
  '     run     run development server'
  '     test    run tests'
  '     watch   build & watch disk for changes'
].join("\n"))
.alias('p', 'port')
.alias('d', 'debug')
.argv

help = ->
  optimist.showHelp()
  process.exit()

exec = (command = argv._[0]) ->
  return help() unless @[command]
  @[command]()
  switch command
    when 'build' then console.log 'Built application'
    when 'new' then console.log "Created new application #{argv._[1]}"
    when 'watch' then console.log 'Watching application'

module.exports =
  argv: argv
  exec: exec
