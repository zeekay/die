path         = require 'path'
{existsSync} = require './utils'

exports.defaults = require './defaults'

exports.read = (opts, config) ->
  if not existsSync config
    config = path.join opts.base, opts.configPath, config
  try
    _opts = require config
    for key, val of _opts
      opts[key] = val
  catch err
  opts
