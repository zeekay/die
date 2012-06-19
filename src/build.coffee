fs     = require 'fs'
path   = require 'path'
wrench = require 'wrench'
minify = require './minify'

generatePath = (orig, ext) ->
  out = path.basename(orig).split('.')
  out.pop()
  out.push ext
  out.join('.')

module.exports = (die) ->
  dest    = die.options.dist or 'dist/'
  js      = die.options.main
  css     = die.options.css
  jsPath  = die.options.jsPath
  cssPath = die.options.cssPath

  wrench.rmdirSyncRecursive dest, true
  fs.mkdirSync dest

  if path.existsSync die.options.public
    wrench.copyDirSyncRecursive die.options.public, dest

  if js and path.existsSync js
    if not jsPath
      jsPath = generatePath js, 'js'

    source = die.hemPackage().compile()
    if die.options.minify
      source = minify.js source

    fs.writeFileSync path.join(dest, jsPath), source

  if css and path.existsSync css
    if not cssPath
      cssPath = generatePath css, 'css'

    source = die.cssPackage().compile()
    if die.options.minify
      source = minify.css source

    fs.writeFileSync path.join(dest, cssPath), source
