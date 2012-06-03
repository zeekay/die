fs     = require 'fs'
milk   = require 'milk'
path   = require 'path'
wrench = require 'wrench'
{argv} = require './cli'

module.exports = create = ->
  dirName = argv._[1]
  opts =
    name: path.basename dirName
    user: process.env.USER

  wrench.copyDirSyncRecursive __dirname + '/../template', dirName
  for file in wrench.readdirSyncRecursive dirName
    filePath = path.join dirName, file
    if fs.statSync(filePath).isFile()
      template = fs.readFileSync filePath
      fs.writeFileSync filePath, milk.render(template.toString(), opts)
