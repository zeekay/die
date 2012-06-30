{dirname, join} = require 'path'
{existsSync}    = require './utils'

module.exports = (die) ->
  base = die.options.base
  watch = []
  die.build()
  for dir in (dirname join base, lib for lib in die.options?.js?.after or [])
    unless dir in watch
      watch.push dir
  for dir in (dirname join base, lib for lib in die.options?.js?.before or [])
    unless dir in watch
      watch.push dir
  js = die.options?.jsBundle?.entry
  css = die.options?.cssBundle?.entry
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
