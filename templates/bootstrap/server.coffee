#!/usr/bin/env coffee
hemlock   = require 'hemlock'

module.exports = app = hemlock.createServer()

if require.main == module
  app.run()
