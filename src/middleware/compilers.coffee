fs = require 'fs'
{dirname, join} = require 'path'
{concatRead, resolve} = require '../utils'

# Bundle compilers, meant to be added as methods to a bundle object.
module.exports =
  css: (base = '') ->
    after = @after or []
    before = @before or []
    main = join base, @main
    filename = resolve ['.css', '.styl'], main
    functions = @functions or {}
    include = @include or []
    plugins = @plugins or []

    # Bundle dat up!
    bundle = ->
      body = fs.readFileSync filename, 'utf8'
      stylus = require('stylus')(body)
        .set('filename', filename)
        .include(dirname(filename))

      for path in include
        stylus.include path

      if plugins.length == 0
        plugins = [require('die-bootstrap'), require('nib')]

      for plugin in plugins
        stylus.use plugin()

      for name, fn of functions
        stylus.define name, fn

      res = ''
      stylus.render (err, css) ->
        throw err if err
        res = css
      res

    # Return compiler for middleware
    compiler = (cb) ->
      try
        cb null, bundle()
      catch err
        cb err, ''

  js: (base='') ->
    opts = {}
    for k, v of @
      opts[k] = v

    # Get absolute path
    opts.main  =  join base, @main
    opts.after  = (join base, src for src in @after or [])
    opts.before = (join base, src for src in @before or [])

    # Create bundler
    requisite = require('requisite')(opts)

    # Return compiler for middleware
    compiler = (cb) ->
      requisite.bundle (err, body) ->
        cb err, body
