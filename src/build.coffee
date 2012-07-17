fs     = require 'fs'
minify = require './minify'
wrench = require 'wrench'
{dirname, join} = require 'path'

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

  # compile bundles
  for bundle in [opts.jsBundle, opts.cssBundle]
    do (bundle) ->
      if bundle and existsSync dirname bundle.entry
        bundle.create(opts.base) (err, body) ->
          fs.writeFileSync join(dest, bundle.url), body
