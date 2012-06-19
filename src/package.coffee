{Package}  = require 'hem/lib/package'
Dependency = require 'hem/lib/dependency'
Stitch     = require 'hem/lib/stitch'
stitch     = require 'hem/assets/stitch'
detective  = require 'fast-detective'
fs         = require 'fs'
path       = require 'path'
coffee     = require 'coffee-script'

class DiePackage extends Package
  compileModules: ->
    @dependency or= new Dependency @dependencies
    @stitch       = new Stitch @paths
    jsFiles       = @stitch.resolve()
    @modules      = @dependency.resolve().concat jsFiles

    # Create a list of unresolved modules
    unresolved    = []
    known = (id for {id} in @modules)
    for js in jsFiles
      if path.extname(js.filename) == '.coffee'
        src = coffee.compile fs.readFileSync(js.filename).toString()
      else
        src = fs.readFileSync(js.filename).toString()

      required = detective src
      for module in required
        if module not in known
          unresolved.push module

    if unresolved.length > 0
      modules = new Dependency unresolved
      @modules.push.apply @modules, modules.resolve()

    stitch(identifier: @identifier, modules: @modules)

module.exports =
  DiePackage: DiePackage
  createPackage: (config) ->
    new DiePackage(config)
