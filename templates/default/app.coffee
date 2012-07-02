md  = require('markdown').markdown
fs  = require 'fs'

app = require('die')
  base: __dirname

app.extend ->
  @set 'view options'
    layout: false

  @get '/', ->
    fs.readFile __dirname + '/README.md', 'utf8', (err, content) =>
      @render 'index', readme: md.toHTML content

module.exports = app
