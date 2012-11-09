fs = require 'fs'
{dirname, join} = require 'path'
{resolve} = require '../utils'

compiledCss = null

# Bundle compilers, add as methods to your bundle config.
exports.css = ->
  base = @base or ''
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

    for plugin in plugins
      stylus.use plugin

    for name, fn of functions
      stylus.define name, fn

    css = ''
    stylus.render (err, _css) ->
      throw err if err
      css = _css
    css

  # Return compiler for middleware
  compiler = (cb) ->
    if compiledCss
      return cb null, compiledCss

    try
      css = bundle()
      count = before.length + after.length

      if count > 0
        # reverse to preserve expected order
        before.reverse()

        # check if we're done
        done = ->
          if count == 0
            compiledCss = css
            cb null, css

        # append css assets
        for asset in after
          if typeof asset == 'function'
            asset (err, out) ->
              css = out + css
              done()
          else
            fs.readFile asset, 'utf8', (err, out) ->
              css = out + asset
              done()

        # prepend css assets
        for asset in before
          if typeof asset == 'function'
            asset (err, out) ->
              css = out + css
              done()
          else
            fs.readFile asset, 'utf8', (err, out) ->
              css = out + asset
              done()
    catch err
      compiledCss = ''
      cb err, ''

exports.js = ->
  base = @base or ''
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
