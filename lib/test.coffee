{exec}    = require 'child_process'
path      = require 'path'

model.exports = (args) ->
  # add current working directory to NODE_PATH to simplify requires
  nodePath = process.env.NODE_PATH or ''
  process.env.NODE_PATH = "#{nodePath}:"
  bin = 'node_modules/mocha/bin/mocha'
  if not path.existsSync bin
    bin = 'mocha'
  exec "#{bin} #{args}", (err, stdout, stderr) ->
    console.log stdout
    console.error stderr
