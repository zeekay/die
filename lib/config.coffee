path   = require 'path'
wrench = require 'wrench'
fs     = require 'fs'

addVendor = ->
  vendorPath = path.join process.cwd(), @options.vendor
  for file in wrench.readdirSyncRecursive vendorPath
    filePath = path.join vendorPath, file
    console.log filePath
    if fs.statSync(filePath).isFile() and path.extname(filePath) == '.js'
      @options.libs.push filePath
  @options.libs

readConfig = (config = 'defaults') ->
  configPath = path.join process.cwd(), @options.configPath, config
  try
    config = require configPath
    @options[key] = value for key, value of config
  catch error
    return

  @options

module.exports =
  addVendor: addVendor
  readConfig: readConfig
