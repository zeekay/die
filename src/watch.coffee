{dirname, existsSync, join} = require 'path'

module.exports = (die) ->
  base = die.options.base
  watch = []
  die.build()
  for dir in (dirname join base, lib for lib in die.options?.js?.libs or [])
    unless dir in watch
      watch.push dir
  js = die.options?.jsBundle?.main
  css = die.options?.cssBundle?.main
  watch.push dirname join base, js if js
  watch.push dirname join base, css if css

  for dir in watch
    continue unless existsSync dir
    require('watch').watchTree dir, (file, curr, prev) =>
      if curr and (curr.nlink is 0 or +curr.mtime isnt +prev?.mtime)
        console.log "#{file} changed.  Rebuilding."
        die.build()

  console.log 'watching:'
  for dir in watch
    console.log "    #{dir}"
