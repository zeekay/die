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
  ({filename}) ->
    # We only support fs.watch
    return if not fs.watch

    if watched[filename]
      watched[filename].close()
    try
      watched[filename] = fs.watch filename, -> reload()
    catch err
      if err.code == 'EMFILE'
        console.log 'Too many open files, try to increase the number of open files'
        process.exit()
      else
        throw err

module.exports = (opts = {}) ->
  # Configure forking behavior
  cluster.setupMaster
    silent: false
    # Have to use compiled worker.coffee
    exec: join __dirname, '..', 'lib/worker.js'

  # Fork workers
  for i in [1..opts.workers]
    worker = cluster.fork
      app: opts.app
      port: opts.port
    if opts.reload
      worker.on 'message', watch

  cluster.on "listening", (worker, addr) ->
    console.log "worker #{worker.id} listening on #{addr.address}:#{addr.port}"

  cluster.on "exit", (worker, code, signal) ->
    exitCode = worker.process.exitCode
    console.log "worker #{worker.id} died (#{exitCode}). restarting..."
    worker = cluster.fork
      app: opts.app
      port: opts.port
    if opts.reload
      worker.on 'message', watch

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
