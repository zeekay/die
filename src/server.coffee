express = require 'express'
extend  = require './extend'
{existsSync} = require './utils'
{join, dirname} = require 'path'

exports.extend = (app, func) ->
  extend app, func

exports.createServer = (func) ->
  extend express.createServer(), func

exports.default = (opts) ->
  ->
    @configure ->
      @set 'port', opts.port

      # setup views
      dir = join opts.base, '/views'
      if existsSync dir
        @set 'views', dir
        # use jade by default
        @set 'view engine', 'jade'

      # setup static file serving
      dir = join opts.base, opts.staticPath
      if existsSync dir
        @use express.static dir
      else
        # serve cwd if public dir doesn't exist.
        @use express.static opts.base

    @development ->
      # Serve bundles
      bundles = {}

      for bundle in [opts.jsBundle, opts.cssBundle]
        if bundle and existsSync dirname bundle.entry
          bundles[bundle.url] = bundle.create bundle, opts.base

      if Object.keys(bundles).length > 0
        @use require('./middleware')(bundles)

      # Enable logger and pretty stack traces
      @use express.logger()
      @use express.errorHandler {dumpExceptions: true, showStack: true}

    @production ->
      @use express.errorHandler()

    @test ->
      # listen on a different port when running tests
      @set 'port', opts.port + 1
