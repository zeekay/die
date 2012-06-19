{Package}  = require 'hem/lib/package'
Dependency = require 'hem/lib/dependency'
Stitch     = require 'hem/lib/stitch'
coffee     = require 'coffee-script'
detective  = require 'fast-detective'
fs         = require 'fs'
path       = require 'path'
stitch     = require 'hem/assets/stitch'

toArray = (value = []) ->
  if Array.isArray(value) then value else [value]

class CssPackage
  constructor: (cssPath) ->
    try
      @path = require.resolve(path.resolve(cssPath))
    catch e

  compile: ->
    return unless @path
    delete require.cache[@path]
    require @path

class JsPackage extends Package
  constructor: (config = {}) ->
    @identifier   = config.identifier
    @libs         = toArray(config.libs)
    @paths        = toArray(config.paths)
    @dependencies = toArray(config.dependencies)

    # automatically add base dir of mainJs to search path
    if config.main
      @paths.concat [path.dirname path.resolve config.main]

  compileModules: ->
    @dependency or= new Dependency @dependencies
    @stitch       = new Stitch @paths
    jsFiles       = (js for js in @stitch.resolve() when js)
    @modules      = @dependency.resolve().concat jsFiles

    # Create a list of unresolved modules
    unresolved    = []
    known = (id for {id} in @modules)
    for js in jsFiles
      if js.ext == '.coffee'
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
  CssPackage: CssPackage
  createCss: (cssPath) ->
    new CssPackage(cssPath)

  JsPackage: JsPackage
  createJs: (config) ->
    new JsPackage(config)
