path   = require 'path'

exports.defaults = require './defaults'

exports.readConfig = (options, name = 'default') ->
  configPath = path.join process.cwd(), options.configPath, name
  try
    config = require configPath
    for key, value of config
      options[key] = value
  catch err
  options
