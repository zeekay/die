path   = require 'path'

exports.defaults = require './defaults'

exports.update = (options, config = 'defaults') ->
  configPath = path.join options.configPath, config
  try
    config = require configPath
    options[key] = value for key, value of config
  catch error

  # automatically add js entrypoint's dir to search path
  options.paths.concat [path.dirname options.main]

  options
