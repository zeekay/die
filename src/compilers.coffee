fs        = require 'fs'
path      = require 'path'
compilers = require 'hem/lib/compilers'

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
      .include(path.dirname(filename))
      .use(bootstrap())
      .use(nib())
      .render (err, css) ->
        throw err if err
        result = css
    result

module.exports = compilers
