fs     = require 'fs'
path   = require 'path'
wrench = require 'wrench'

module.exports = ->
  src  = @options.public or '.'
  dest = @options.dist or 'dist/'

  wrench.rmdirSyncRecursive dest, true
  fs.mkdirSync dest
  wrench.copyDirSyncRecursive src, dest

  source = @hemPackage().compile()
  fs.writeFileSync path.join(dest, @options.jsPath), source

  source = @cssPackage().compile()
  fs.writeFileSync path.join(dest, @options.cssPath), source
