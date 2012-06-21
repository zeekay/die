{calculate} = require './deep-thought'

class App
  template = require './templates/index'
  render: ->
    $('#content').html template answer: calculate()

module.exports = new App()
