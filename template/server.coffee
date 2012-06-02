hemlock = require 'hemlock'

app = hemlock.createServer()

app.listen 3000, ->
  console.log '{{name}} running @ http://localhost:' + app.settings.port
