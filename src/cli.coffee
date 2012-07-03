program         = require 'jade/node_modules/commander'
{existsSync}    = require './utils'
{dirname, join} = require 'path'

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
      die = require('./index')
        buildPath: opts.output
        css:
          entry: opts.css
          url: opts.cssPath
        js:
          entry: opts.js
          url: opts.jsPath
        minify: opts.minify
      die.build()

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
    .option('-w, --workers [number]', 'number of workers processes to run')
    .action ({app, port, workers}) ->
      Die = require './die'

      port ?= process.env.PORT ?= 3000
      workers ?= 1

      if not app
        try
          mod = require.resolve process.cwd()
        catch err
          mod = false

        if mod
          app = require mod
        else
          app = new Die
          app.defaultServer()

      require('./run') app,
        port: port
        workers: workers

  program
    .command('test')
    .description('  run tests')
    .action ->
      require('./test')()

  program
    .command('watch')
    .description('  watch for changes and rebuild project')
    .action ->
      die = require('./index')
        base: process.cwd()
      require('./watch') die

  help = -> console.log program.helpInformation()

  program.parse process.argv

  help() unless program.args.length
