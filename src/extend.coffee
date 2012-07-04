{patcher} = require './utils'

# Extend an express app with a zappa-ish DSL
module.exports = (app, func) ->

  # create monkey patching utilities
  {patch, unpatch} = patcher app

  # configuration shortcuts
  app.__orig__configure = app.configure
  patch 'configure', (env, func) ->
    if func
      app.__orig__configure env, ->
        func.call app
    else
      app.__orig__configure ->
        env.call app

  for env in ['development', 'production', 'test']
    patch env, (func) ->
      app.__orig__configure env, ->
        func.call app

  # setup specialized route handlers
  for verb in ['all', 'get', 'post', 'put', 'del']
    do (verb) ->
      patch verb, (path, handler) ->
        app["__orig_#{verb}"] path, (req, res, next) ->
          ctx =
            app: app
            body: req.body
            next: next
            params: req.params
            query: req.query
            request: req
            response: res
            session: req.session
            settings: app.settings
            json: -> res.json.apply res, arguments
            redirect: -> res.redirect.apply res, arguments
            render: -> res.render.apply res, arguments
            send: -> res.send.apply res, arguments
          handler.apply ctx, req.params

  # Shortcut to add routes
  patch 'addRoutes', (routes) ->
    if not Array.isArray routes
      routes = [routes]

    for route in routes
      route.call app

  # Expose middleware
  patch 'middleware', require './middleware'

  # Extend app using func
  func.call app

  # Unpatch app
  unpatch()

  # Return extended app
  app
