fs       = require 'fs'
mote     = require 'mote'
version  = require('../package.json').version
wrench   = require 'wrench'

path     = require 'path'
exists   = path.existsSync
basename = path.basename
join     = path.join

utils    = require './utils'
encoding = utils.getEncoding
exec     = utils.exec

module.exports = (name, {config, template, install, production}) ->
  template = template or 'default'
  src = join __dirname, '../templates', template
  dest = name

  ctx =
    name: basename dest
    user: process.env.USER
    dieVersion: version

  # update context with config options.
  if config
    for key, val of require config
      ctx[key] = val

  # make sure we don't clobber an existing directory.
  if exists dest
    return console.log "#{dest} already exists."

  # copy template to dest
  wrench.copyDirSyncRecursive src, dest

  # compile templates with configuration
  for file in wrench.readdirSyncRecursive dest

    # skip vendor files
    if /^vendor/.test file
      continue

    # treat all other files as templates and inject context
    file = join dest, file

    if fs.statSync(file).isFile()
      buffer = fs.readFileSync file
      if encoding(buffer) is 'utf8'
        template = mote.compile buffer.toString()
        fs.writeFileSync file, template ctx

  if install
    cmd = "npm install"
    cmd += " --production" if production
    exec cmd, cwd: join(process.cwd(), ctx.name)

  console.log 'The die has been cast.'
