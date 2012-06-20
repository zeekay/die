fs            = require 'fs'
mote          = require 'mote'
path          = require 'path'
wrench        = require 'wrench'
pkg           = require '../package.json'
{getEncoding} = require './utils'

module.exports = (name, {config, template}, ctx = {}) ->
  template = template or 'default'
  src = path.join __dirname, '../templates', template
  dest = name

  ctx.name = path.basename dest
  ctx.user = process.env.USER
  ctx.dieVersion = pkg.version

  # update context with config options.
  if config
    for key, val of config
      ctx[key] = val

  # make sure we don't clobber an existing directory.
  if path.existsSync dest
    return console.log "#{dest} already exists."

  # copy template to dest
  wrench.copyDirSyncRecursive src, dest

  # compile templates with configuration
  for file in wrench.readdirSyncRecursive dest

    # skip vendor files
    if /^vendor/.test file
      continue

    # treat all other files as templates and inject context
    filePath = path.join dest, file
    if fs.statSync(filePath).isFile()
      buffer = fs.readFileSync(filePath)
      if getEncoding(buffer) is 'utf8'
        template = mote.compile buffer.toString()
        fs.writeFileSync filePath, template ctx
