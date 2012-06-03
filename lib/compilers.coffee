bootstrap = require 'bootstrap-hemlock'
fs        = require 'fs'
jade      = require 'jade'
nib       = require 'nib'
path      = require 'path'
stylus    = require 'stylus'

module.exports = compilers =
  jade: (fn) ->
    content = fs.readFileSync fn, 'utf8'
    compiled = jade.compile content,
      client: true
      debug: false
      compileDebug: false
    return "module.exports = #{compiled};"

  styl: (fn) ->
    content = fs.readFileSync fn, 'utf8'
    result = ''
    stylus(content)
      .include(path.dirname(fn))
      .use(bootstrap())
      .use(nib())
      .render((err, css) ->
        throw err if err
        result = css
      )
    result
