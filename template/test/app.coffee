assert  = require 'assert'
app     = require '../server'
zombie  = require 'zombie'
browser = new zombie.Browser

describe 'test {{name}}', ->
  describe 'GET /', ->
    before (done) ->
      app.listen app.settings.port, ->
        browser.visit "http://localhost:#{app.settings.port}/", -> done()

    it 'has title', ->
      title = browser.text 'title'
      assert.equal title, '{{name}}'
