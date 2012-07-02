fs = require 'fs'
{dirname, join} = require 'path'
{concatRead, resolve} = require './utils'

module.exports =
  createCssBundler: ({entry, include, plugins, functions}, base='') ->
    include = include or []
    plugins = plugins or []
    functions = functions or {}
    entry = join base, entry
    filename = resolve ['.css', '.styl'], entry

    bundler =
      compile: ->
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

  createJsBundler: (opts, base='') ->
    # clone opts to prevent options getting mangled
    _opts = {}
    for k, v of opts
      _opts[k] = v

    _opts.entry  = join base, opts.entry
    _opts.after  = (join base, src for src in opts.after or [])
    _opts.before = (join base, src for src in opts.before or [])
    require('requisite').createBundler _opts
