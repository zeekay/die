path = require 'path'
app  = process.env.app
port = process.env.port

# Require coffee-script if necessary.
require 'coffee-script' if path.extname(app) is '.coffee'

# Notify master of files to watch for changes.
require('./watcher') (filename) ->
  process.send
    type: 'watch'
    filename: filename

# Try to require die app
try
  app = require app
  if app.constructor.name != 'Die'
    throw new Error 'Not a valid die app'
catch err
  process.send
    type: 'error'
    error: err.toString()
  process.exit()

app.extend ->
  @configure ->
    # Enable error handler for non-production enviroments
    if process.env.NODE_ENV != 'production'
      for middleware in @stack
        if middleware.handle.name == 'errorHandler'
          # Already has an errorHandler, return
          return

      @use @middleware.errorHandler
        dumpExceptions: true
        showStack: true

# Run app!
app.run port: port
