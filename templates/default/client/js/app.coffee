deepThought = require 'deep-thought'

class App
  template = require 'templates/index'
  render: ->
    $('#content').html template answer: deepThought.calculate()

module.exports = new App()
