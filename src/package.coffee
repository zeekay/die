Dependency = require './dependency'
coffee     = require 'coffee-script'
compilers  = require './compilers'
detective  = require 'fast-detective'
fs         = require 'fs'
path       = require 'path'
stitch     = require './stitch'

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

class JsPackage
  constructor: (config = {}) ->
    @identifier   = config.identifier or 'require'
    @libs         = toArray(config.libs)
    @paths        = toArray(config.paths)
    @dependencies = toArray(config.dependencies)

    # automatically add base dir of mainJs to search path
    if config.main
      @paths.concat [path.dirname path.resolve config.main]

  compileModules: ->
    @dependency or= new Dependency @dependencies
    @stitch       = new stitch.Stitch @paths
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

    stitch.template
      identifier: @identifier
      modules: (JSON.stringify(module.id) + ": function(exports, require, module) {#{module.compile()}}" for module in @modules).join(', ')

  compileLibs: ->
    (fs.readFileSync(path, 'utf8') for path in @libs).join("\n")

  compile: (minify) ->
    result = [@compileLibs(), @compileModules()].join("\n")
    result = uglify(result) if minify
    result

module.exports =
  CssPackage: CssPackage
  createCss: (cssPath) ->
    new CssPackage(cssPath)

  JsPackage: JsPackage
  createJs: (config) ->
    new JsPackage(config)
