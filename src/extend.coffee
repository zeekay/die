# Extend an express app with a zappa-ish DSL
module.exports = extend = (app, func) ->

  patched = []

  patch = (name, replacement) ->
    if app[name]
      app["__orig__#{name}"] = app[name]
    app[name] = replacement
    patched.push name

  unpatch = ->
    for name in patched
      if app["__orig__#{name}"]
        app[name] = app["__orig__#{name}"]
        delete app["__orig__#{name}"]
      else
        delete app[name]

  # configuration shortcuts
  patch 'configure', (env, func) ->
    if not func
      app.__configure ->
        env.call app
    else
      app.__configure env, ->
        func.call app

  for env in ['development', 'production', 'test']
    do (env) ->
      patch env, (func) ->
        app.configure env, func

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
