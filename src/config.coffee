path   = require 'path'
wrench = require 'wrench'
fs     = require 'fs'

exports.readConfig = (config = 'defaults') ->
  configPath = path.join process.cwd(), @options.configPath, config
  try
    config = require configPath
    @options[key] = value for key, value of config
  catch error

  # automatically add js entrypoint's dir to search path
  @options.paths.concat [path.dirname @options.main]

  @options
