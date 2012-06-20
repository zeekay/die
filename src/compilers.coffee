fs        = require 'fs'
{dirname} = require 'path'

compilers = {}

compilers.js = compilers.css = (path) ->
  fs.readFileSync path, 'utf8'

require.extensions['.css'] = (module, filename) ->
  source = JSON.stringify(compilers.css(filename))
  module._compile "module.exports = #{source}", filename

compilers.coffee = (path) ->
  coffee = require 'coffee-script'
  coffee.compile(fs.readFileSync(path, 'utf8'), filename: path)

compilers.eco = (path) ->
  eco = require 'eco'
  content = eco.precompile fs.readFileSync path, 'utf8'
  "module.exports = #{content}"

compilers.jeco = (path) ->
  eco = require 'eco'
  content = eco.precompile fs.readFileSync path, 'utf8'
  """
  module.exports = function(values){
    var $  = jQuery, result = $();
    values = $.makeArray(values);

    for(var i=0; i < values.length; i++) {
      var value = values[i];
      var elem  = $((#{content})(value));
      elem.data('item', value);
      $.merge(result, elem);
    }
    return result;
  };
  """

require.extensions['.jeco'] = require.extensions['.eco']

compilers.tmpl = (path) ->
  content = fs.readFileSync(path, 'utf8')
  "var template = jQuery.template(#{JSON.stringify(content)});\n" +
  "module.exports = (function(data){ return jQuery.tmpl(template, data); });\n"

require.extensions['.tmpl'] = (module, filename) ->
  module._compile(compilers.tmpl(filename))

compilers.jade = (filename) ->
  jade = require 'jade'
  content = fs.readFileSync filename, 'utf8'
  compiled = jade.compile content,
    client: true
    debug: false
    compileDebug: false
  return "module.exports = #{compiled};"

compilers.styl = (filename) ->
    bootstrap = require 'bootstrap-hemlock'
    nib       = require 'nib'
    stylus    = require 'stylus'
    content = fs.readFileSync filename, 'utf8'
    result = ''
    stylus(content)
      .include(dirname(filename))
      .use(bootstrap())
      .use(nib())
      .render (err, css) ->
        throw err if err
        result = css
    result

require.extensions['.styl'] = (module, filename) ->
    source = JSON.stringify(compilers.styl(filename))
    module._compile "module.exports = #{source}", filename

module.exports = compilers
