# Asset bundling middleware
module.exports = (bundles={}, opts={}) ->
  maxAge = opts.maxAge or 0

  for k, v of bundles
    if k.match /.js$/
      bundles[k].compiler ?= require('./compilers').js.call bundles[k]
      bundles[k].contentType ?= 'application/javascript'

    else if k.match /.css$/
      bundles[k].compiler ?= require('./compilers').css.call bundles[k]
      bundles[k].contentType ?= 'text/css'

    if not v.main? and not v.compiler?
      # remove invalid bundle
      delete bundles[k]

  _bundle = (req, res, next) ->
    url = req.url
    return next() if not (compiler = bundles[url]?.compiler)

    # Set headers
    now = new Date().toUTCString()
    res.setHeader 'Date', now unless res.getHeader 'Date'
    res.setHeader 'Cache-Control', 'public, max-age=' + (maxAge / 1000) unless res.getHeader 'Cache-Control'
    res.setHeader 'Last-Modified', now unless res.getHeader 'Last-Modified'
    res.setHeader bundles[url].contentType or 'application/octet-stream'

    if req.method == 'HEAD'
      res.writeHead 200
      return res.end()

    return next() if req.method != 'GET'

    compiler (err, body) ->
      return next err if err

      res.writeHead 200
      res.end body, 'utf8'

  # Wrap this is a named function to make debugging easier.
  `function bundle(req, res, next) { return _bundle(req, res, next); };`
