bundle = require './bundle'
fs     = require 'fs'
minify = require './minify'
wrench = require 'wrench'

path   = require 'path'
exists = path.existsSync
join   = path.join

module.exports = (opts) ->
  dest = join opts.base, opts.buildPath or 'dist/'
  console.log opts.minify

  # remove previous build
  wrench.rmdirSyncRecursive dest, true
  fs.mkdirSync dest

  # copy static assets
  dir = join opts.base, opts.staticPath
  if exists dir
    wrench.copyDirSyncRecursive dir, dest

  try
    js = bundle.js opts.js, opts.base
    src = js.bundle()
    if opts.minify
      src = minify.js src
    fs.writeFileSync join(dest, opts.js.url), src
  catch err
    console.log err

  try
    css = bundle.css opts.css, opts.base
    src = css.bundle()
    if opts.minify
      src = minify.css src
    fs.writeFileSync join(dest, opts.css.url), src
  catch err
    console.log err
