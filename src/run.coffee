cluster = require("cluster")
{join}  = require 'path'

reload = ->
  for id, worker of cluster.workers
    worker.destroy()

module.exports = (app, {port, watch, workers} = {}) ->
  app = app.app if app.app
  workers ?= 1
  watch ?= true
  port ?= process.env.PORT or 3000

  if cluster.isMaster
    # Handle keypresses
    process.stdin.resume()
    process.stdin.setEncoding "utf8"
    process.stdin.setRawMode true
    process.stdin.on "data", (char) ->
      switch char
        when "\u0003" # ctrl-c
          process.exit()
        when "\u0004" # ctrl-d
          process.exit()
        when "q"
          process.exit()
        when "\u0012" # ctrl-r
          reload()
        when "r"
          reload()

    # Fork workers
    for i in [1..workers]
      cluster.fork()

    cluster.on "listening", (worker, addr) ->
      console.log "worker #{worker.id} up @ http://#{addr.address}:#{addr.port}"

    cluster.on "exit", (worker, code, signal) ->
      exitCode = worker.process.exitCode
      console.log "worker #{worker.id} died (#{exitCode}). restarting..."
      cluster.fork()
  else
    app.listen port
