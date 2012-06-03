{argv} = require './cli'

module.exports =  options =
  # path to configuration files
  configPath: 'config/'

  # js entry/exit
  main: './app/js/app'
  jsPath: '/app.js'

  # css entry/exit
  css: './app/css/app'
  cssPath: '/app.css'

  # Add load paths
  paths: ['./app/js']

  # Load before any other js
  libs: []

  # autopopulate libs with files from this dir
  vendor: 'vendor/'

  # npm/Node dependencies
  dependencies: []

  # static dir
  public: './public'

  port: process.env.PORT or argv.port or 3333
