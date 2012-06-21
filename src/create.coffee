fs       = require 'fs'
mote     = require 'mote'
path     = require 'path'
version  = require('../package.json').version
wrench   = require 'wrench'

utils    = require './utils'
encoding = utils.getEncoding
exec     = utils.exec

module.exports = (name, {config, template, install, production}) ->
  template = template or 'default'
  src = path.join __dirname, '../templates', template
  dest = name

  ctx =
    name: path.basename dest
    user: process.env.USER
    dieVersion: version

  # update context with config options.
  if config
    for key, val of require config
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
      if encoding(buffer) is 'utf8'
        template = mote.compile buffer.toString()
        fs.writeFileSync filePath, template ctx

  if install
    cmd = "npm install"
    cmd += " --production" if production
    exec cmd, cwd: path.join(process.cwd(), ctx.name)
