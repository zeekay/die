path    = require 'path'
program = require 'commander'
pkg     = require '../package.json'

program
  .version(pkg.version)
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
    Die = require './die'
    opts =
      dist: opts.output
      css: opts.css
      cssPath: opts.cssPath
      main: opts.js
      jsPath: opts.jsPath
      minify: opts.minify or true
    for k,v of opts
      if not v
        delete opts[k]
    app = new Die opts
    app.build()

program
  .command('new [name]')
  .description('  create new project')
  .usage('[name] [options]')
  .option('-t, --template [name]', 'template to use')
  .option('-c, --config [config.json]', 'configuration file to supply context variables from')
  .action (name, opts = {}) ->
    if not name
      return console.log 'Name of project is required'
    require('./create') name, opts

program
  .command('run')
  .description('  serve project')
  .option('-p, --port [number]', 'port to run server on')
  .action (opts) ->
    if opts.port
      process.env.PORT = opts.port
    require('./index').run()

program
  .command('test')
  .description('  run tests')
  .action ->
    require('./test')()

program
  .command('watch')
  .description('  watch for changes and rebuild project')
  .action ->
    die = require './index'
    require('./watch') die

program.parse process.argv
