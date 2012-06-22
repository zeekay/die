md   = require('markdown').markdown
read = require('fs').readFileSync
die  = require('../../src')
  base: __dirname

app = die.createServer ->

  readme = md.toHTML read __dirname + '/README.md', 'utf8'

  @set 'view options'
    layout: false

  @get '/', ->
    @render 'index', readme: readme

module.exports = app
