program         = require 'jade/node_modules/commander'
{existsSync}    = require './utils'
{dirname, join} = require 'path'

# Return app in current working directory, or default Die app
appOrDefault = (opts) ->
  # Try to resolve current directory
  try
    mod = require.resolve process.cwd()
  catch err
    mod = false

  # Try to require Die app
  {Die} = require('./die')
  if mod
    app = require mod
    # If we actually have a Die app instance, use it
    if app instanceof Die
      return app

  # Return default Die app
  new Die

# Commandline handler
module.exports = ->
  program
    .version(require('../package.json').version)
    .usage('[command] [options]')

  program
    .command('build')
    .description('  assemble project')
    .option('-o, --output [dir]', 'output dir')
    .option('-m, --minify', 'minify output')
    .option('--css [in]', 'CSS entrypoint')
    .option('--css-path [out]', 'path to compiled CSS')
    .option('--js [in]', 'Javascript entrypoint')
    .option('--js-path [out]', 'path to compiled Javascript')
    .action (opts) ->
      app = appOrDefault()
      app.updateOptions
        buildPath: opts.output
        cssBundle:
          entry: opts.css
          url: opts.cssPath
          minify: opts.minify
        jsBundle:
          entry: opts.js
          url: opts.jsPath
          minify: opts.minify
      app.build()

  program
    .command('new [name]')
    .description('  create new project')
    .usage('[name] [options]')
    .option('-t, --template [name]', 'template to use')
    .option('-c, --config [config.json]', 'configuration file to supply context variables from')
    .option('-i, --install', 'run npm install automatically')
    .option('-p, --production', 'only install production dependencies')
    .action (name, opts = {}) ->
      if not name
        return console.log 'Name of project is required'
      require('./create') name, opts

  program
    .command('run')
    .description('  serve project')
    .option('-a, --app [module]', 'app to run')
    .option('-p, --port [number]', 'port to run server on')
    .option('-r, --reload', 'automatically reload on file changes')
    .option('-w, --workers [number]', 'number of workers processes to run')
    .action ({app, port, reload, workers}) ->
      port ?= process.env.PORT ?= 3000
      workers ?= 1

      {run} = require './run'
      if reload
        require('./reloader') require('./run').reload

      app ?= appOrDefault()

      run app,
        port: port
        workers: workers

  program
    .command('test')
    .description('  run tests')
    .option('-a, --args [arguments]', 'arguments for mocha')
    .action ({args}) ->
      require('./test') args

  program
    .command('watch')
    .description('  watch for changes and rebuild project')
    .action ->
      app = appOrDefault()
      require('./watch') app

  help = -> console.log program.helpInformation()

  program.parse process.argv

  help() unless program.args.length
