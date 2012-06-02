child    = require 'child_process'
express  = require 'express'
fs       = require 'fs'
jade     = require 'jade'
milk     = require 'milk'
optimist = require 'optimist'
path     = require 'path'
wrench   = require 'wrench'

Hem      = require 'hem'

argv = optimist.usage([
  ' Usage: hem COMMAND',
  '',
  ' Commands:',
  '     build   serialize application to disk',
  '     create  bootstrap a new app',
  '     server  start a dynamic development server',
  '     watch   build & watch disk for changes'
].join("\n"))
.alias('p', 'port')
.alias('d', 'debug')
.argv

class Hemlock extends Hem
  constructor: (options = {}) ->
    @options[key] = value for key, value of options
    @readConfig()

  options:
    # path to configuration files
    configPath: 'config/'

    # js entry/exit
    main: './app/js/app'
    jsPath: '/app.js'

    # css entry/exit
    css: './app/css/app'
    cssPath: '/app.css'

    # Add load paths
    paths: ['./app/js']

    # Load before any other js
    libs: []

    # npm/Node dependencies
    dependencies: []

    # static dir
    public: './public'

    port: process.env.PORT or argv.port or 3333

  create: ->
    dirName = argv._[1]
    opts =
      name: path.basename dirName
      user: process.env.USER

    wrench.copyDirSyncRecursive __dirname + '/../template', dirName
    for file in wrench.readdirSyncRecursive dirName
      filePath = path.join dirName, file
      if fs.statSync(filePath).isFile()
        template = fs.readFileSync filePath
        fs.writeFileSync filePath, milk.render(template.toString(), opts)

  createServer: ->
    app = express.createServer()
    app.configure =>
      app.set 'port', @options.port
      app.use app.router

      if path.existsSync @options.public
        app.use express.static @options.public

    app.configure 'test', =>
      app.set 'port', @options.port + 1

    app.configure 'development', ->
      app.use express.errorHandler {dumpExceptions: true, showStack: true}

    app.configure 'production', ->
      app.use express.errorHandler()

    app.get @options.cssPath, (req, res) =>
      res.header 'Content-Type', 'text/css'
      res.send @cssPackage().compile()

    app.get @options.jsPath, (req, res) =>
      res.header 'Content-Type', 'application/javascript'
      res.send @hemPackage().compile()

    @readConfig app.settings.env

    app.run = (cb) ->
      app.listen app.settings.port, ->
        console.log "up & running @ http://localhost:#{app.settings.port}"
        if cb
          cb()
      app

    app

  server: ->
    app = @createServer()
    app.run ->
      if process.platform == 'darwin'
        child.exec "open http://localhost:#{app.settings.port}", -> return

  help: ->
    optimist.showHelp()
    process.exit()

  readConfig: (config = 'defaults') ->
    configPath = path.join process.cwd(), @options.configPath, config
    try
      config = require configPath
      @options[key] = value for key, value of config
    catch error
      return

    @options

  exec: (command = argv._[0]) ->
    if not command
      command = 'server'
    return @help() unless @[command]
    @[command]()
    switch command
      when 'build' then console.log 'Built application'
      when 'create' then console.log "Created new application #{argv._[1]}"
      when 'watch' then console.log 'Watching application'

Hemlock::compilers.jade = (path) ->
  opts =
    client: true
    debug: false
    compileDebug: false
  compiled = jade.compile(fs.readFileSync(path, 'utf8'), opts)
  return "module.exports = #{compiled};"

hemlock = new Hemlock
hemlock.Hemlock = Hemlock
module.exports = hemlock
