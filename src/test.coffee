fs     = require 'fs'
path   = require 'path'
{exec} = require './utils'

module.exports = (args = '--compilers coffee:coffee-script -R spec -t 5000 -c') ->
  if (not path.existsSync 'test') or (fs.readdirSync('test').length == 0)
    return console.log 'Tests not found.'
  nodePath = process.env.NODE_PATH or ''
  process.env.NODE_PATH = "#{nodePath}:"
  bin = 'node_modules/mocha/bin/mocha'
  if not path.existsSync bin
    bin = 'mocha'
  exec "#{bin} #{args}"
