assert  = require 'assert'
app     = require '../server'
zombie  = require 'zombie'
browser = new zombie.Browser

describe '{{name}} app', ->
  describe 'GET /', ->
    before (done) ->
      browser.visit "http://localhost:#{app.settings.port}/", -> done()

    it 'has title', ->
      title = browser.text 'title'
      assert.equal title, '{{name}}'
