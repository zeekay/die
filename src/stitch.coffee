npath        = require 'path'
fs           = require 'fs'
compilers    = require './compilers'
{modulerize} = require './resolve'
{flatten}    = require './utils'

class Stitch
  constructor: (@paths = []) ->
    @paths = (npath.resolve(path) for path in @paths)

  resolve: ->
    flatten(@walk(path) for path in @paths)

  # Private

  walk: (path, parent = path, result = []) ->
    return unless npath.existsSync(path)
    for child in fs.readdirSync(path)
      child = npath.join(path, child)
      stat  = fs.statSync(child)
      if stat.isDirectory()
        @walk(child, parent, result)
      else
        module = new Module(child, parent)
        result.push(module) if module.valid()
    result

class Module
  constructor: (@filename, @parent) ->
    @ext = npath.extname(@filename).slice(1)
    @id  = modulerize(@filename.replace(npath.join(@parent, '/'), ''))

  compile: ->
    compilers[@ext](@filename)

  valid: ->
    !!compilers[@ext]

exports.Stitch = Stitch

exports.template = require('mote').compile '''
{{identifier}}(function(/*! Stitch !*/) {
  if (!this.{{identifier}}) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
      module   = cache[path] || cache[indexPath]
      if (module) {
        return module;
      } else if (fn = modules[path] || modules[path = indexPath]) {
        module = {id: path, exports: {}};
        cache[path] = module.exports;
        fn(module.exports, function(name) {
          return require(name, dirname(path));
        }, module);
        return cache[path] = module.exports;
      } else {
        throw 'module ' + name + ' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.{{identifier}} = function(name) {
      return require(name, '');
    }
    this.{{identifier}}.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.{{identifier}}.modules = modules;
    this.{{identifier}}.cache   = cache;
  }
  return this.{{identifier}}.define;
}).call(this)({
{{modules}}
});
'''
