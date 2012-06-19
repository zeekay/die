assert = require 'assert'
foo    = require '../client/js/foo'

describe 'client/js/foo', ->
  describe 'foo.bar()', ->
    it 'should return 42', ->
      assert.equal foo.bar(), 42
