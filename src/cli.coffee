program = require 'commander'
path    = require 'path'
pkg     = require '../package.json'

program
  .version(pkg.version)
  .usage('[command] [options]')

program
  .command('build')
  .description('  assemble project')
  .option('-o, --output [dir]')
  .action (arg) -> console.log arg.output

program
  .command('new [name]')
  .description('  create new project')
  .usage('[name] [options]')
  .option('-t, --template [name]', 'template to use')
  .option('-c, --config [config.json]', 'configuration file to supply context variables from')
  .action (arg) -> console.log arg

program
  .command('run')
  .description('  serve project')
  .usage('[options]')
  .option('-p, --port [number]', 'port to run server on')
  .action (arg) -> console.log arg

program
  .command('test')
  .description('  run tests')
  .usage('[options]')
  .option('-a, --args [arguments]', 'arguments to pass to mocha')
  .action (arg) -> console.log arg

program
  .command('watch')
  .description('  watch for changes and rebuild project')
  .action (arg) -> console.log arg

program.parse process.argv
