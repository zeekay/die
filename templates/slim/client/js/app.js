var deepThought = require('deep-thought');

exports.render = function() {
  var el = document.getElementById('content');
  el.innerHTML = '<p>The answer to life, the universe, and everything: ' + deepThought.calculate() + '</p>';
};
