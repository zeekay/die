fs     = require 'fs'
path   = require 'path'
wrench = require 'wrench'
rimraf = require 'rimraf'

module.exports = ->
  src  = @options.public or '.'
  dest = @options.dist or 'dist/'

  if path.existsSync dest
    rimraf.sync dest

  fs.mkdirSync dest
  wrench.copyDirSyncRecursive src, dest

  source = @hemPackage().compile(not argv.debug)
  fs.writeFileSync path.join(dest, @options.jsPath), source

  source = @cssPackage().compile()
  fs.writeFileSync path.join(dest, @options.cssPath), source
