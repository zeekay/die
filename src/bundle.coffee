bootstrap  = require 'bootstrap-hemlock'
browserify = require 'browserify'
compilers  = require './compilers'
fs         = require 'fs'
jade       = require 'jade'
nib        = require 'nib'
stylus     = require 'stylus'

path       = require 'path'
basename   = path.basename
dirname    = path.dirname
join       = path.join
exists     = path.existsSync

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

    for ext, fn of compilers
      b.register '.'+ext, fn

    # prepend all declared libs
    libs = (join base, lib for lib in libs)
    b.prepend concatRead libs

    # guess node_modules dir
    nm = join(base, 'node_modules')
    ln = join dirname(join(base, main)), 'node_modules'

    # create a symlink to node_modules for browserify
    # this is a bit of a hack xD
    fs.symlinkSync nm, ln, 'dir' if exists nm and not exists ln

    # require JS entry point
    b.require join base, main

    # unlink
    fs.unlinkSync ln if exists ln

    b
