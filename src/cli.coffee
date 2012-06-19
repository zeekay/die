path    = require 'path'
program = require 'commander'
die     = require './die'
pkg     = require '../package.json'

program
  .version(pkg.version)
  .usage('[command] [options]')

program
  .command('build')
  .description('  assemble project')
  .option('-o, --output [dir]')
  .action (opts) ->
    die.build opts

program
  .command('new [name]')
  .description('  create new project')
  .usage('[name] [options]')
  .option('-t, --template [name]', 'template to use')
  .option('-c, --config [config.json]', 'configuration file to supply context variables from')
  .action (name, opts) ->
    die.create name, opts

program
  .command('run')
  .description('  serve project')
  .option('-p, --port [number]', 'port to run server on')
  .action (opts) ->
    die.run opts

program
  .command('test')
  .description('  run tests')
  .option('-a, --args [arguments]', 'arguments to pass to mocha')
  .action (opts) ->
    die.test opts

program
  .command('watch')
  .description('  watch for changes and rebuild project')
  .action ->
    die.watch()

program.parse process.argv
