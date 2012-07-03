fs = require 'fs'
{dirname, join} = require 'path'
{concatRead, resolve} = require './utils'

module.exports =
  # When this function is called the context will be the cssBundle options
  createCssBundle: (base = '') ->
    include = @include or []
    plugins = @plugins or []
    functions = @functions or {}
    entry = join base, @entry
    filename = resolve ['.css', '.styl'], entry

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

  createJsBundle: (base='') ->
    opts = {}
    for k, v of @
      opts[k] = v

    # Get absolute path
    opts.entry  =  join base, @entry
    opts.after  = (join base, src for src in @after or [])
    opts.before = (join base, src for src in @before or [])

    # Create bundler
    requisite = require('requisite').createBundler opts

    # Return compiler for middleware
    compiler = (cb) ->
      requisite.bundle (err, body) ->
        cb err, body
