cluster = require("cluster")
numCPUs = require("os").cpus().length

reload = ->
  for id, worker of cluster.workers
    worker.destroy()

module.exports = (app, opts={}) ->
  port = opts.port or 3000
  numWorkers = opts.workers or numCPUs

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
    for i in [1..numWorkers]
      cluster.fork()

    started = 0
    cluster.on "listening", (worker, addr) ->
      started += 1
      if started == numWorkers
        console.log "die running @ http://#{addr.address}:#{addr.port}"
      else if started > numWorkers
        console.log "worker #{worker.id} up @ http://#{addr.address}:#{addr.port}"

    cluster.on "exit", (worker, code, signal) ->
      exitCode = worker.process.exitCode
      console.log "worker #{worker.id} died (#{exitCode}). restarting..."
      cluster.fork()
  else
    app.listen port
