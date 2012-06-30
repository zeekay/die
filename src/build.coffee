bundle = require './bundle'
fs     = require 'fs'
minify = require './minify'
wrench = require 'wrench'

path   = require 'path'
join   = path.join

{existsSync} = require './utils'

module.exports = (opts) ->
  dest = join opts.base, opts.buildPath or 'dist/'

  # remove previous build
  wrench.rmdirSyncRecursive dest, true
  fs.mkdirSync dest

  # copy static assets
  dir = join opts.base, opts.staticPath
  if existsSync dir
    wrench.copyDirSyncRecursive dir, dest

  try
    cssBundle = bundle.createCssBundle opts.cssBundle, opts.base
    src = cssBundle.compile()
    if opts.minify
      src = minify.css src
    fs.writeFileSync join(dest, opts.cssBundle.url), src
  catch err
    console.trace err

  try
    jsBundle = bundle.createJsBundle opts.jsBundle, opts.base
    jsBundle.bundle (err, src) ->
      if opts.minify
        src = minify.js src
      fs.writeFileSync join(dest, opts.jsBundle.url), src
  catch err
    console.trace err
