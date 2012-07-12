express = require 'express'
path    = require 'path'

# Variables passed in by cluster master
app     = process.env.app
port    = process.env.port

# Require coffee-script if necessary.
require 'coffee-script' if path.extname(app) is '.coffee'

# Notify master of files to watch for changes.
require('./watcher') (filename) ->
  process.send filename: filename

# Get express app
app = require(app).app

do ->
  if process.env.NODE_ENV != 'production'
    for middleware in app.stack
      if middleware.handle.name == 'errorHandler'
        # Already has an errorHandler, return
        return

    # Enable error handler for non-production enviroments
    app.use express.errorHandler dumpExceptions: true, showStack: true

# Run app!
app.listen port
