die = require('../../src')
  base: __dirname

app = die.createServer ->
  @set 'view options'
    layout: false

  @get '/', ->
    require('fs').readFile __dirname + '/README.md', (err, data) =>
      readme = require('markdown').markdown.toHTML data.toString()
      @render 'index', readme: readme

  @get '/answer', ->
    @json
      answer: require('./client/js/deep-thought').calculate()

module.exports = app
