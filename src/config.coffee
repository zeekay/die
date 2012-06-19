path   = require 'path'

exports.defaults = require './defaults'

exports.readConfig = (options, config) ->
  try
    _options = require config
    for key, val of _options
      options[key] = val
  catch err
  options
