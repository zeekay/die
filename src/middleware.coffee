middleware = {}

# Export common express middleware lazily.
for mw in ['bodyParser', 'cookieParser', 'errorHandler', 'methodOverride', 'session']
  do (mw) ->
    Object.defineProperty middleware, mw,
      enumerable: true
      get: ->
        require('express')[mw]

# Connect/Express middleware for bundling static resources such as JavaScript/CoffeeScript.
middleware.bundle = (bundles, opts={}) ->
  maxAge = opts.maxAge or 0
  (req, res, next) ->
    url = req.url
    return next() if not (fn = bundles[url])

    # Set headers
    now = new Date().toUTCString()
    res.setHeader 'Date', now unless res.getHeader 'Date'
    res.setHeader 'Cache-Control', 'public, max-age=' + (maxAge / 1000) unless res.getHeader 'Cache-Control'
    res.setHeader 'Last-Modified', now unless res.getHeader 'Last-Modified'

    if url.indexOf('.js') > url.length-3
      res.setHeader 'Content-Type', 'application/javascript'
    else if url.indexOf('.css') > url.length-4
      res.setHeader 'Content-Type', 'text/css'

    if req.method == 'HEAD'
      res.writeHead 200
      return res.end()

    return next() if req.method != 'GET'

    fn (err, body) ->
      return next err if err

      res.writeHead 200
      res.end body, 'utf8'


module.exports = middleware
