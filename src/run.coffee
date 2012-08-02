cluster  = require 'cluster'
fs       = require 'fs'
{join}   = require 'path'
{notify} = require './utils'

# Reload all workers
reload = ->
  notify
    title: 'Die'
    message: 'Change detected, automatically reloading'
  for id, worker of cluster.workers
    worker.destroy()

# Start up debugger
debug = ->
  for id, worker of cluster.workers
    # Only kill first worker
    pid = worker.process.pid
    require('child_process').exec "kill -s 30 #{pid}"
    return

# Watch files for changes
watch = do ->
  watched = {}
  (filename) ->
    # We only support fs.watch
    return if not fs.watch

    if watched[filename]
      watched[filename].close()
    try
      watched[filename] = fs.watch filename, ->
        reload()
    catch err
      if err.code == 'EMFILE'
        console.log 'Too many open files, try to increase the number of open files'
        process.exit()
      else
        throw err

workerMessage = (message) ->
  switch message.type
    when 'error'
      console.error message.error
      process.exit()
    when 'watch'
      watch message.filename

module.exports = (opts = {}) ->
  # Spawn a worker by forking
  fork = ->
    worker = cluster.fork
      app: opts.app
      port: opts.port
    worker.on 'message', workerMessage

  # Configure forking behavior
  cluster.setupMaster
    silent: false
    exec: join __dirname, '..', 'lib/worker.js'

  cluster.on 'listening', (worker, addr) ->
    console.log "worker #{worker.id} listening on http://#{addr.address}:#{addr.port}"

  cluster.on 'exit', (worker, code, signal) ->
    console.log "worker #{worker.id} exit(#{exitCode}), restarting"
    fork()

  # Fork workers
  for i in [1..opts.workers]
    fork()

  # Handle keypresses
  process.stdin.resume()
  process.stdin.setEncoding "utf8"
  process.stdin.setRawMode true
  process.stdin.on "data", (char) ->
    switch char
      when "\u0003" # ctrl-c
        process.exit()
      when "\u0004" # ctrl-d
        debug()
      when "d"
        debug()
      when "q"
        process.exit()
      when "\u0012" # ctrl-r
        reload()
      when "r"
        reload()
