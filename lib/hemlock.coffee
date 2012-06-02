child    = require 'child_process'
express  = require 'express'
fs       = require 'fs'
milk     = require 'milk'
optimist = require 'optimist'
path     = require 'path'
wrench   = require 'wrench'

Hem      = require 'hem'

help = ->
  optimist.showHelp()
  process.exit()

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

  options:
    # configuration file
    config: './config/app.json'

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

  server: ->
    app = express.createServer()
    app.configure =>
      app.use app.router

      if path.existsSync @options.public
        app.use express.static @options.public

    app.get @options.cssPath, (req, res) =>
      res.header 'Content-Type', 'text/css'
      res.send @cssPackage().compile()

    app.get @options.jsPath, (req, res) =>
      res.header 'Content-Type', 'application/javascript'
      res.send @hemPackage().compile()

    app.listen @options.port
    console.log "hemlock running @ http://localhost:#{@options.port}"

    if process.platform == 'darwin'
      child.exec "open http://localhost:#{@options.port}", -> return

  exec: (command = argv._[0]) ->
    return help() unless @[command]
    @[command]()
    switch command
      when 'build' then console.log 'Built application'
      when 'create' then console.log "Created new application #{argv._[1]}"
      when 'watch' then console.log 'Watching application'

module.exports = Hemlock
