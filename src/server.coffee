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

      if opts.bundles
        for k of opts.bundles
          opts.bundles[k].base = opts.base
        @use require('./middleware').bundle opts.bundles

    @test ->
      # listen on a different port when running tests
      @set 'port', opts.port + 1

    @
