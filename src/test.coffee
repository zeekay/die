fs   = require 'fs'
path = require 'path'

{exec, existsSync} = require './utils'

module.exports = (args = '--compilers coffee:coffee-script -R spec -t 5000 -c') ->
  if (not existsSync 'test') or (fs.readdirSync('test').length == 0)
    return console.log 'Tests not found.'
  nodePath = process.env.NODE_PATH or ''
  process.env.NODE_PATH = "#{nodePath}:"
  bin = 'node_modules/mocha/bin/mocha'
  if not existsSync bin
    bin = 'mocha'
  exec "#{bin} #{args}"
