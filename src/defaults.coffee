module.exports =  options =
  # path to configuration files
  configPath: 'config/'

  # js entry/exit
  main: './client/js/app'
  jsPath: '/app.js'

  # Add load paths
  paths: ['./client/js']

  # npm/Node dependencies
  dependencies: []

  # css entry/exit
  css: './client/css/app'
  cssPath: '/app.css'

  # Load before any other js
  libs: []

  # static dir
  public: './public'

  port: process.env.PORT or 3000
