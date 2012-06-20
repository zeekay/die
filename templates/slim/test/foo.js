var assert = require('assert'),
    foo = require('client/js/foo');

describe('client/js/foo', function() {
  describe('foo.bar()', function() {
    it('should return 42', function() {
      assert.equal(foo.bar(), 42);
    });
  });
});
