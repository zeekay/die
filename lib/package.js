// Generated by CoffeeScript 1.3.3
var Dependency, DiePackage, Package, Stitch, coffee, detective, fs, path, stitch,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

Package = require('hem/lib/package').Package;

Dependency = require('hem/lib/dependency');

Stitch = require('hem/lib/stitch');

stitch = require('hem/assets/stitch');

detective = require('fast-detective');

fs = require('fs');

path = require('path');

coffee = require('coffee-script');

DiePackage = (function(_super) {

  __extends(DiePackage, _super);

  function DiePackage() {
    return DiePackage.__super__.constructor.apply(this, arguments);
  }

  DiePackage.prototype.compileModules = function() {
    var id, js, jsFiles, known, module, modules, required, src, unresolved, _i, _j, _len, _len1;
    this.dependency || (this.dependency = new Dependency(this.dependencies));
    this.stitch = new Stitch(this.paths);
    jsFiles = this.stitch.resolve();
    this.modules = this.dependency.resolve().concat(jsFiles);
    unresolved = [];
    known = (function() {
      var _i, _len, _ref, _results;
      _ref = this.modules;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        id = _ref[_i].id;
        _results.push(id);
      }
      return _results;
    }).call(this);
    for (_i = 0, _len = jsFiles.length; _i < _len; _i++) {
      js = jsFiles[_i];
      if (path.extname(js.filename) === '.coffee') {
        src = coffee.compile(fs.readFileSync(js.filename).toString());
      } else {
        src = fs.readFileSync(js.filename).toString();
      }
      required = detective(src);
      for (_j = 0, _len1 = required.length; _j < _len1; _j++) {
        module = required[_j];
        if (__indexOf.call(known, module) < 0) {
          unresolved.push(module);
        }
      }
    }
    if (unresolved.length > 0) {
      modules = new Dependency(unresolved);
      this.modules.push.apply(this.modules, modules.resolve());
    }
    return stitch({
      identifier: this.identifier,
      modules: this.modules
    });
  };

  return DiePackage;

})(Package);

module.exports = {
  DiePackage: DiePackage,
  createPackage: function(config) {
    return new DiePackage(config);
  }
};