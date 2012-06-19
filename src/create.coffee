fs     = require 'fs'
mote   = require 'mote'
path   = require 'path'
wrench = require 'wrench'

module.exports = (name, {config, template}, ctx = {}) ->
  template = template or 'default'
  src = path.join __dirname, '../templates', template
  dest = name
  if config
    ctx = require config
  ctx.name = path.basename dest
  ctx.user = process.env.USER

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
      template = mote.compile fs.readFileSync(filePath).toString()
      fs.writeFileSync filePath, template ctx
