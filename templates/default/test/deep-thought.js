var assert = require('assert'),
    deepThought = require('client/js/deep-thought');

describe('client/js/deep-thought', function() {
  describe('deepThought.calculate()', function() {
    it('Should return the anser to Life, The Universe, and Everything', function() {
      assert.equal(deepThought.calculate(), 42);
    });
  });
});
