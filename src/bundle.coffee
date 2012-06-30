bootstrap  = require 'die-bootstrap'
fs         = require 'fs'
jade       = require 'jade'
requisite  = require 'requisite'
nib        = require 'nib'
stylus     = require 'stylus'

path       = require 'path'
dirname    = path.dirname
join       = path.join

utils      = require './utils'
concatRead = utils.concatRead
resolve    = utils.resolve

module.exports =
  createCssBundle: ({entry}, base='') ->
    entry = join base, entry
    filename = resolve ['.css', '.styl'], entry
    bundle =
      compile: ->
        body = fs.readFileSync filename, 'utf8'
        result = ''
        stylus(body)
          .set('filename', filename)
          .include(dirname(filename))
          .use(bootstrap())
          .use(nib())
          .render (err, css) ->
            throw err if err
            result = css
        result

  createJsBundle: (opts, base='') ->
    # clone opts
    _opts = {}
    for k,v of opts
      _opts[k] = v

    _opts.entry  = join base, opts.entry
    _opts.after  = (join base, src for src in opts.after or [])
    _opts.before = (join base, src for src in opts.before or [])
    requisite.createBundler _opts
