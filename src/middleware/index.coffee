middleware = {}

# Export bundle middleware
middleware.bundle = require './bundle'

# Export connect middleware
connectMiddleware = [
  'basicAuth'
  'bodyParser'
  'compress'
  'cookieParser'
  'cookieSession'
  'csrf'
  'directory'
  'errorHandler'
  'favicon'
  'json'
  'limit'
  'logger'
  'methodOverride'
  'multipart'
  'query'
  'responseTime'
  'session'
  'static'
  'staticCache'
  'timeout'
  'urlencoded'
  'vhost'
]

# Export common express middleware lazily.
for mw in connectMiddleware
  do (mw) ->
    Object.defineProperty middleware, mw,
      enumerable: true
      get: ->
        require('express/node_modules/connect').middleware[mw]

module.exports = middleware
