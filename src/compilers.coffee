exports.jade = (body, filename) ->
  jade = require 'jade'
  @ignore filename
  func = jade.compile body,
    client: true
    debug: false
    compileDebug: false
  "module.exports = #{func.toString()}"
