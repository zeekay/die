# createBundler = require '../src/bundle'
# fs            = require 'fs'
# should        = require('chai').should()
# {existsSync}  = require '../src/utils'
# {join}        = require 'path'

# describe 'bundle', ->
#   # Declare bundlers in outer scope so tests have access to them.
#   bundler = null
#   content = null
#   reqFiles = [
#     'require.define(["/a","70f886d883"]'
#     'require.define(["/b","8908bb92f8"]'
#     'require.define(["/c","318af1af20"]'
#     'require.define(["/entry","21568343a3"]'
#   ]
#   reqDirectories = [
#     'require.define(["/test/assets/foo","58c67562d2"]'
#   ]
#   reqModules = [
#     'require.define(["/node_modules/mod","e63313c6a9"]'
#   ]
#   reqTemplates = [
#     'require.define(["/test/assets/template","04e021b689"]'
#   ]
#   prelude = 'require = (function() {'
#   jadeRuntime = 'jade=function(exports){Array.isArray||(Array.isArray=function(arr)'
#   callEntry = "require('21568343a3');"
#   afterScripts = "alert('after');"
#   beforeScripts = "alert('before');"

#   before (done) ->
#     # Create bundlers
#     bundler = createBundler
#       after:  join __dirname, '/assets/vendor/after.js'
#       before: join __dirname, '/assets/vendor/before.js'
#       entry:  join __dirname, '/assets/entry'

#     # Generate dummy npm module if necessary.
#     mod = join __dirname, '..', 'node_modules', 'mod'
#     if not existsSync mod
#       fs.mkdirSync mod
#       fs.writeFileSync join(mod, 'index.js'), "module.exports = {x: 42};"

#     # Save output of bundle() for tests, call twice to ensure there are no issues with caching
#     bundler.bundle (err, _content) ->
#       throw err if err
#       content = _content
#       done()

#   describe 'bundle#bundle()', ->
#     it 'should include the appropriate prelude', ->
#       content.should.have.string prelude

#     it 'should find and define all absolute/relatively required files properly', ->
#       for str in reqFiles
#         content.should.have.string str

#     it 'should find and define all absolute/relatively required directories properly', ->
#       for str in reqDirectories
#         content.should.have.string str

#     it 'should find and define all modules required from node_modules', ->
#       for str in reqModules
#         content.should.have.string str

#     it 'should include appropriate vendor scripts after bundled code', ->
#       content.should.have.string afterScripts

#     it 'should include appropriate vendor scripts before bundled code', ->
#       content.should.have.string beforeScripts

#     it 'should find and define all modules required from node_modules', ->
#       for str in reqModules
#         content.should.have.string str

#     it 'should find and define all jade templates', ->
#       for str in reqTemplates
#         content.should.have.string str

#     it 'should include the jade runtime', ->
#       content.should.have.string jadeRuntime

#     it 'should automatically call the entry module', ->
#       content.should.have.string callEntry

#   describe 'bundle#bundle() pt. ii: return of the bundle', ->
#     it 'should still pass previous tests after being bundled up again', (done) ->
#       bundler.bundle (err, content) ->
#         throw err if err
#         for str in reqFiles.concat reqDirectories, reqModules, reqTemplates, prelude, jadeRuntime, callEntry, afterScripts, beforeScripts
#           content.should.have.string str
#         done()
