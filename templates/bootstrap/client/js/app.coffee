class App
  template = require 'templates/index'
  constructor: ->
    $('#content').html template()

module.exports = new App
