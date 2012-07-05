{patcher} = require './utils'

# Extend an express app with a zappa-ish DSL
module.exports = extend = (app, func) ->

  # create monkey patching utilities
  {patch, unpatch} = patcher app

  # configuration shortcuts
  configure = null
  patch 'configure', (original) ->
    # Save a reference for the other helper methods
    configure = original
    (env, func) ->
      if func
        original env, ->
          func.call app
      else
        original ->
          env.call app

  for env in ['development', 'production', 'test']
    patch env, ->
      do (env) ->
        (func) ->
          configure.call app, env, ->
            func.call app

  # setup specialized route handlers
  for verb in ['all', 'get', 'post', 'put', 'del']
    # SNTX TODO delete console.logs
    # SNTX STOP TODO get previous commit and console log req, res, etc..
    console.log verb
    patch verb, (original) ->
      (path, handler) ->
        original path, (req, res, next) ->
          console.log original.toString()
          console.log path
          #console.log req.name
          #console.log res.name
          #console.log next.name
          ctx =
            app: app
            body: req.body
            next: next
            params: req.params
            query: req.query
            req: req
            res: res
            session: req.session
            settings: app.settings
            json: -> res.json.apply res, arguments
            redirect: -> res.redirect.apply res, arguments
            render: -> res.render.apply res, arguments
            send: -> res.send.apply res, arguments
          handler.apply ctx, req.params

  # Shortcut to add routes
  patch 'addRoutes', ->
    (routes) ->
      #console.log "SNTX: inside addRoutes"
      if not Array.isArray routes
        routes = [routes]

      for route in routes
        #console.log route.toString()
        extend app, route

  # Expose middleware
  patch 'middleware', -> require './middleware'

  # Extend app using func
  func.call app

  # Unpatch app
  unpatch()

  # Return extended app
  app
