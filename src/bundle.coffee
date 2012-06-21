bootstrap  = require 'bootstrap-hemlock'
browserify = require 'browserify'
fs         = require 'fs'
jade       = require 'jade'
nib        = require 'nib'
stylus     = require 'stylus'

path       = require 'path'
basename   = path.basename
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

  js: ({main, libs}, base = '') ->
    b = browserify()
    b.register '.jade', (body, filename) ->
      @ignore filename
      func = jade.compile body,
        client: true
        debug: false
        compileDebug: false
      "module.exports = #{func.toString()}"
    libs = (join base, lib for lib in libs)
    b.prepend concatRead libs
    b.require "./#{basename main}", dirname: dirname join base, main
    b
