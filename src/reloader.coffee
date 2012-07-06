path = require 'path'
fs   = require 'fs'
vm   = require 'vm'
{patcher} = require './utils'
{watchTree} = require 'watch'

module.exports = (trigger) ->
  if require('cluster').isMaster
    watch = do ->
      watched = []
      (file) ->
        dir = path.dirname file
        if dir not in watched
          watched.push dir
          options =
            persistent: true
            interval: 500
            ignoreDotfiles: true
          watchTree dir, options, (file, curr, prev) =>
            if curr and (curr.nlink is 0 or +curr.mtime isnt +prev?.mtime)
              trigger()

    hooks = {}

    updateHooks = ->
      for ext, handler of require.extensions
        do (ext, handler) ->
          if hooks[ext] != require.extensions[ext]
            hooks[ext] = require.extensions[ext] = (module, filename) ->
              # Watch module if it hasn't been loaded before
              watch module.filename unless module.loaded

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
