exports.js = (source) ->
  parser = require('uglify-js').parser
  uglify = require('uglify-js').uglify

  ast = parser.parse source
  ast = uglify.ast_mangle(ast)
  ast = uglify.ast_squeeze(ast)
  uglify.gen_code ast

exports.css = (source) ->
  require('clean-css').process source
