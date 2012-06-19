path = require 'path'

module.exports = (die) ->
  watched = []
  die.build()
  for dir in (path.dirname(lib) for lib in die.options.libs).concat die.options.css, die.options.paths
    continue unless not dir in watched
    continue unless path.existsSync dir
    watched.push dir
    console.log dir
    require('watch').watchTree dir, (file, curr, prev) =>
      if curr and (curr.nlink is 0 or +curr.mtime isnt +prev?.mtime)
        console.log "#{file} changed.  Rebuilding."
        die.build()
