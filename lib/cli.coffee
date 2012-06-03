optimist  = require 'optimist'

argv = optimist.usage([
  ' Usage: hem COMMAND',
  '',
  ' Commands:',
  '     build   serialize application to disk',
  '     create  bootstrap a new app',
  '     server  start a dynamic development server',
  '     watch   build & watch disk for changes'
].join("\n"))
.alias('p', 'port')
.alias('d', 'debug')
.argv

help = ->
  optimist.showHelp()
  process.exit()

exec = (command = argv._[0]) ->
  if not command
    command = 'server'
  return help() unless @[command]
  @[command]()
  switch command
    when 'build' then console.log 'Built application'
    when 'create' then console.log "Created new application #{argv._[1]}"
    when 'watch' then console.log 'Watching application'

module.exports =
  argv: argv
  exec: exec
