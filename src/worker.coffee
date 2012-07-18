path = require 'path'
app  = process.env.app
port = process.env.port

# Require coffee-script if necessary.
require 'coffee-script' if path.extname(app) is '.coffee'

# Notify master of files to watch for changes.
require('./watcher') (filename) ->
  process.send filename: filename

# Get express app
app = require(app)

app.extend ->
  @configure ->
    if process.env.NODE_ENV != 'production'
      for middleware in @stack
        if middleware.handle.name == 'errorHandler'
          # Already has an errorHandler, return
          return

      # Enable error handler for non-production enviroments
      @use @middleware.errorHandler dumpExceptions: true, showStack: true

# Run app!
app.run port: port
