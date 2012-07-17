program      = require 'jade/node_modules/commander'
{existsSync} = require './utils'
{dirname, join, resolve} = require 'path'

# Return app in current working directory, or default Die app
appOrDefault = (app) ->
  app = if app then resolve app else null
  # Try to resolve current directory
  try
    require.resolve app ? process.cwd()
  catch err
    resolve './die'

# Commandline handler
module.exports = ->
  program
    .command('*')
    .version(require('../package.json').version)
    .usage('[command] [options]')
    .action (file) ->
      # Reconstruct arguments and run again
      args = process.argv.splice 0, 2
      for arg in ['run', '--app', file]
        args.push arg
      program.parse args

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
      app = appOrDefault app
      port ?= process.env.PORT ?= 3000
      reload ?= false
      workers ?= 1

      require('./run')
        app: app
        port: port
        reload: reload
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
