path      = require 'path'
vm        = require 'vm'
{patcher} = require './utils'
{watch}   = require 'fs'

module.exports = (callback) ->
  hooks = {}

  updateHooks = ->
    for ext, handler of require.extensions
      do (ext, handler) ->
        if hooks[ext] != require.extensions[ext]
          hooks[ext] = require.extensions[ext] = (module, filename) ->
            # Watch module if it hasn't been loaded before
            callback module.filename unless module.loaded

            # Invoke original handler
            handler module, filename

            # Make sure the module did not hijack the handler
            updateHooks()

  # Hook 'em.
  updateHooks()

  # Patch VM module.
  {patch} = patcher vm
  methods =
    createScript: 1
    runInThisContext: 1
    runInNewContext: 2
    runInContext: 2

  for method, idx of methods
    patch method, (original) ->
      ->
        watch(file) if file = arguments[idx]
        original arguments
