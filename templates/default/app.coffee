die = require('die')
  base: __dirname

app = die.createServer ->
  @set 'view options'
    layout: false

  @get '/', ->
    @render 'index'

  @get '/readme', ->
    require('fs').readFile __dirname + '/README.md', (err, data) =>
      readme = require('markdown').markdown.toHTML data.toString()
      @render 'readme', readme: readme

  @get '/answer', ->
    @json
      answer: require('./client/js/deep-thought').calculate()

module.exports = app
