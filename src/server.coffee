express = require 'express'
extend  = require './extend'
{existsSync} = require './utils'
{join, dirname} = require 'path'

exports.extend = (app, func) ->
  extend app, func

exports.createServer = (func) ->
  app = express()
  extend app, func

exports.default = (opts) ->
  ->
    @configure ->
      @set 'port', opts.port

      # setup views
      dir = join opts.base, '/views'
      if existsSync dir
        @set 'views', dir
        # Use jade by default
        @set 'view engine', 'jade'
        # Disable layouts
        @set 'view options',
          layout: false

    @development ->
      # Enable logging
      @use express.favicon()
      @use express.logger 'dev'

      # setup static file serving
      dir = join opts.base, opts.staticPath
      if existsSync dir
        @use express.static dir
      else
        # serve cwd if public dir doesn't exist.
        @use express.static opts.base

      # Serve bundles
      bundles = {}

      for bundle in [opts.jsBundle, opts.cssBundle]
        if bundle and existsSync dirname bundle.entry
          bundles[bundle.url] = bundle.create opts.base

      if Object.keys(bundles).length > 0
        @use require('./middleware').bundle(bundles)

    @test ->
      # listen on a different port when running tests
      @set 'port', opts.port + 1

    @
