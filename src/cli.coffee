path    = require 'path'
program = require 'commander'
pkg     = require '../package.json'

program
  .version(pkg.version)
  .usage('[command] [options]')

program
  .command('build')
  .description('  assemble project')
  .option('-o, --output [dir]')
  .action (opts) ->
    require('./die').build opts

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
    require('./die').run opts

program
  .command('test')
  .description('  run tests')
  .action ->
    require('./test')()

program
  .command('watch')
  .description('  watch for changes and rebuild project')
  .action ->
    require('./die').watch()

program.parse process.argv
