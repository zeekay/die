bootstrap  = require 'die-bootstrap'
fs         = require 'fs'
jade       = require 'jade'
mandala    = require 'mandala'
nib        = require 'nib'
stylus     = require 'stylus'

path       = require 'path'
dirname    = path.dirname
join       = path.join

utils      = require './utils'
concatRead = utils.concatRead
resolve    = utils.resolve

module.exports =
  css: ({main}, base = '') ->
    main = join base, main
    filename = resolve ['.css', '.styl'], main
    bundler =
      bundle: ->
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

  js: ({main, libs}, base = '', symlink = true) ->
    mandala.createBundle
      entry: join base, main
      prepend: (join base, lib for lib in libs)
