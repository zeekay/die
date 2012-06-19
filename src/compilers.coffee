fs        = require 'fs'
path      = require 'path'

module.exports =
  jade: (fn) ->
    jade = require 'jade'

    content = fs.readFileSync fn, 'utf8'
    compiled = jade.compile content,
      client: true
      debug: false
      compileDebug: false
    return "module.exports = #{compiled};"

  styl: (fn) ->
    bootstrap = require 'bootstrap-hemlock'
    nib       = require 'nib'
    stylus    = require 'stylus'

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
