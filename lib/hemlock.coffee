child     = require 'child_process'
express   = require 'express'
fs        = require 'fs'
jade      = require 'jade'
milk      = require 'milk'
optimist  = require 'optimist'
path      = require 'path'
wrench    = require 'wrench'
bootstrap = require 'bootstrap-hemlock'
stylus    = require 'stylus'
nib       = require 'nib'
Hem       = require 'hem'

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

    # autopopulate libs with files from this dir
    vendor: 'vendor/'

    # npm/Node dependencies
    dependencies: []

    # static dir
    public: './public'

    port: process.env.PORT or argv.port or 3333

  create: ->
    dirName = argv._[1]
    template = argv.template or 'default'
    opts =
      name: path.basename dirName
      user: process.env.USER

    if not path.existsSync template
      template = path.join __dirname, '/../templates', template
      if not path.existsSync template
        console.log 'template not found'
        process.exit()

    wrench.copyDirSyncRecursive template, dirName

    wrench.readdirRecursive dirName, (err, files) ->
      if not files
        return

      for file in files
        if not /^vendor/.test file
          filePath = path.join dirName, file

          do (filePath) ->
            fs.stat filePath, (err, stats) ->
              if stats.isFile()
                fs.readFile filePath, (err, content) ->
                  content = milk.render content.toString(), opts
                  fs.writeFile filePath, content, (err) ->
                    if (err)
                      throw err

  createServer: ->
    app = express.createServer()

    @readConfig app.settings.env

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

  addVendor: ->
    vendorPath = path.join process.cwd(), @options.vendor
    for file in wrench.readdirSyncRecursive vendorPath
      filePath = path.join vendorPath, file
      console.log filePath
      if fs.statSync(filePath).isFile() and path.extname(filePath) == '.js'
        @options.libs.push filePath
    @options.libs

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

Hemlock::compilers.jade = (fn) ->
  content = fs.readFileSync fn, 'utf8'
  compiled = jade.compile content,
    client: true
    debug: false
    compileDebug: false
  return "module.exports = #{compiled};"

Hemlock::compilers.styl = (fn) ->
  content = fs.readFileSync fn, 'utf8'
  result = ''
  stylus(content)
    .include(path.dirname(fn))
    .use(bootstrap())
    .use(nib())
    .render((err, css) ->
      throw err if err
      result = css
    )
  result

hemlock = new Hemlock
hemlock.Hemlock = Hemlock
module.exports = hemlock
