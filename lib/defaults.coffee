{argv} = require './cli'

module.exports =  options =
  # path to configuration files
  configPath: 'config/'

  # js entry/exit
  main: './app/js/app'
  jsPath: '/app.js'

  # Add load paths
  paths: ['./app/js']

  # npm/Node dependencies
  dependencies: []

  # css entry/exit
  css: './app/css/app'
  cssPath: '/app.css'

  # Load before any other js
  libs: []

  # static dir
  public: './public'

  port: process.env.PORT or argv.port or 3333
