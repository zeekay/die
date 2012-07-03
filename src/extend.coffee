# Extend an express app with a zappa-ish DSL
module.exports = extend = (app, func) ->

  # configuration shortcuts
  app.__configure = app.configure

  app.configure = (env, func) ->
    if not func
      app.__configure ->
        env.call app
    else
      app.__configure env, ->
        func.call app

  for env in ['development', 'production', 'test']
    do (env) ->
      app[env] = (func) ->
        app.configure env, func

  # setup specialized route handlers
  for verb in ['all', 'get', 'post', 'put', 'del']
    do (verb) ->
      # save a reference to original
      app["__orig_#{verb}"] = app[verb]

      app[verb] = (path, handler) ->
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
  app.addRoutes = (routes) ->
    if not Array.isArray routes
      routes = [routes]

    for route in routes
      route.call app

  func.call app

  # Reset app.configure
  app.configure = app.__configure
  delete app.__configure
  delete app.development
  delete app.production
  delete app.test

  # Reset verbs
  for verb in ['get', 'post', 'put', 'del']
    delete app[verb]
    delete app["__orig_#{verb}"]

  # Remove sugar
  delete app.addRoutes

  # Return mangled app!
  app
