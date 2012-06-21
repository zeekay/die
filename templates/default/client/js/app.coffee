caesar = require './caesar'

class App
  template = require './templates/index'
  render: ->
    $('#content').html template quote: caesar.quote()

module.exports = new App()
