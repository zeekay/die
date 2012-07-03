###
Hooks into `require()` to watch for modifications of required files.
If a modification is detected, the process exits with code `101`.
###

###
Remove wrapper.js from the argv array
###

###
Set the execPath so that forked child processes will also uses node-dev
###

###
Resolve the location of the main script relative to cwd
###

###
Logs a message to the console. The level is displayed in ANSI colors,
either bright red in case of an error or green otherwise.
###
log = (msg, level) ->
  csi = (if level is "error" then "1;31" else "32")
  console.log "[\u001b[" + csi + "m" + level.toUpperCase() + "\u001b[0m] " + msg

###
Displays a desktop notification (see notify.sh)
###
notify = (title, msg, level) ->
  level = level or "info"
  log title or msg, level
  spawn __dirname + "/notify.sh", [ title or "node.js", msg, __dirname + "/icons/node_" + level + ".png" ]

###
Triggers a restart by terminating the process with a special exit code.
###
triggerRestart = ->
  process.removeListener "exit", checkExitCode
  process.exit 101

###
Sanity check to prevent an infinite loop in case the program
calls `process.exit(101)`.
###
checkExitCode = (code) ->
  if code is 101
    notify "Invalid Exit Code", "The exit code (101) has been rewritten to prevent an infinite loop.", "error"
    process.reallyExit 1

###
Watches the specified file and triggers a restart upon modification.
###
watch = (file) ->
  watchFile file, ->
    notify "Restarting", file + " has been modified"
    triggerRestart()

watchFile = (file, onChange) ->
  fs.stat file, (err, stats) ->
    throw err  if err
    if watchFileSupported
      try
        fs.watchFile file,
          interval: 500
          persistent: true
        , (cur, prev) ->
          onChange()  if cur and +cur.mtime isnt +prev.mtime

        return
      catch e
        watchFileSupported = false

    # No fs.watchFile support, fall back to fs.watch
    fs.watch file, (ev) ->
      if ev is "change"
        fs.stat file, (err, cur) ->
          throw err  if err
          if cur.size isnt stats.size or +cur.mtime isnt +stats.mtime
            stats = cur
            onChange()



createHook = (ext) ->
  (module, filename) ->
    if module.id is main

      ###
      If the main module is required conceal the wrapper
      ###
      module.id = "."
      module.parent = null
      process.mainModule = module
    watch module.filename  unless module.loaded

    ###
    Invoke the original handler
    ###
    origs[ext] module, filename

    ###
    Make sure the module did not hijack the handler
    ###
    updateHooks()

###
(Re-)installs hooks for all registered file extensions.
###
updateHooks = ->
  handlers = require.extensions
  for ext of handlers

    # Get or create the hook for the extension
    hook = hooks[ext] or (hooks[ext] = createHook(ext))
    if handlers[ext] isnt hook

      # Save a reference to the original handler
      origs[ext] = handlers[ext]

      # and replace the handler by our hook
      handlers[ext] = hook

###
Patches the specified method to watch the file at the given argument
index.
###
patch = (obj, method, fileArgIndex) ->
  orig = obj[method]
  obj[method] = ->
    file = arguments_[fileArgIndex]
    watch file  if file
    orig.apply this, arguments_
fs = require("fs")
Path = require("path")
vm = require("vm")
spawn = require("child_process").spawn
process.argv.splice 1, 1
process.argv[0] = process.execPath = process.env.NODE_DEV
main = Path.resolve(process.cwd(), process.argv[1])
watchFileSupported = !!fs.watchFile
origs = {}
hooks = {}
updateHooks()

###
Patch the vm module to watch files executed via one of these methods:
###
patch vm, "createScript", 1
patch vm, "runInThisContext", 1
patch vm, "runInNewContext", 2
patch vm, "runInContext", 2

###
Error handler that displays a notification and logs the stack to stderr.
###
process.on "uncaughtException", (err) ->
  notify err.name, err.message, "error"
  console.error err.stack or err

process.on "exit", checkExitCode
require "coffee-script"  if Path.extname(main) is ".coffee"
require main
