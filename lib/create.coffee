fs     = require 'fs'
milk   = require 'milk'
path   = require 'path'
wrench = require 'wrench'
{argv} = require './cli'

module.exports = create = ->
  template = argv.template or 'default'
  src = path.join __dirname, '../templates', template
  dest = argv._[1]
  ctx = argv.context or {}
  ctx.name = path.basename dest
  ctx.user = process.env.USER

  # copy template to dest
  wrench.copyDirSyncRecursive src, dest

  # inject context into templates
  for file in wrench.readdirSyncRecursive dest

    # skip vendor files
    if /^vendor/.test file
      continue

    # treat all other files as templates and inject context
    filePath = path.join dest, file
    if fs.statSync(filePath).isFile()
      template = fs.readFileSync filePath
      fs.writeFileSync filePath, milk.render(template.toString(), ctx)
