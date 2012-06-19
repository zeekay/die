{exec}    = require 'child_process'
path      = require 'path'

module.exports = (args = '--compilers coffee:coffee-script -R spec -t 5000 -c') ->
  nodePath = process.env.NODE_PATH or ''
  process.env.NODE_PATH = "#{nodePath}:"
  bin = 'node_modules/mocha/bin/mocha'
  if not path.existsSync bin
    bin = 'mocha'
  exec "#{bin} #{args}", (err, stdout, stderr) ->
    console.log stdout
    console.error stderr
