fs      = require 'fs'
path    = require 'path'
{spawn} = require 'child_process'

# The location of exists/existsSync changed in node v0.8.0.
if fs.existsSync
  exports.existsSync = existsSync = fs.existsSync
  exports.exists     = fs.exists
else
  exports.existsSync = existsSync = path.existsSync
  exports.exists     = path.exists

exports.extend = extend = (obj, ext...) ->
  return {} if not obj?
  for other in ext
    for own key, val of other
      if not obj[key]? or typeof val isnt "object"
        obj[key] = val
      else
        obj[key] = extend obj[key], val
  obj

# Monkey-patch, unpatch existing object.
exports.patcher = (obj) ->
  patched = []
  patcher =
    patch: (name, func) ->
      original = obj[name]
      if typeof original is 'function'
        wrapper = ->
          original.apply obj, arguments
        replacement = func wrapper
      else
        replacement = func original
      obj[name] = replacement
      patched.push [name, original]
      return

    unpatch: ->
      while patched.length
        [name, original] = patched.pop()
        if original
          obj[name] = original
        else
          delete obj[name]
      return

exports.concatRead = (files) ->
  if not Array.isArray files
    files = [files]

  # I should really figure out if this is even worth the trouble..
  # in the meantime it's fun to play with Buffers!
  bufs = []
  length = 0
  for file in files
    buf = fs.readFileSync file
    bufs.push buf
    length += buf.length

  concatBuf = new Buffer length
  index = 0
  for buf in bufs
    buf.copy concatBuf, index, 0, buf.length
    index += buf.length

  concatBuf.toString()

exports.resolve = (extensions, entry) ->
  if existsSync entry
    return entry

  for ext in extensions
    filename = entry + ext
    if existsSync filename
      return filename

  err = new Error "Unable to resolve path to #{entry}"
  throw err

exports.getEncoding = (buffer) ->
    # Prepare
    contentStartBinary = buffer.toString('binary',0,24)
    contentStartUTF8 = buffer.toString('utf8',0,24)
    encoding = 'utf8'

    # Detect encoding
    for i in [0...contentStartUTF8.length]
        charCode = contentStartUTF8.charCodeAt(i)
        if charCode is 65533 or charCode <= 8
            # 8 and below are control characters (e.g. backspace, null, eof, etc.)
            # 65533 is the unknown character
            encoding = 'binary'
            break

    # Return encoding
    return encoding

exports.exec = (args, callback) ->
  # Simple serial execution of commands, no error handling
  serial = (arr) ->
    complete = 0
    iterate = ->
      exports.exec arr[complete], ->
        complete += 1
        if complete == arr.length
          return
        else
          iterate()
    iterate()
    # passed callback as second argument
    if typeof opts is 'function'
      callback = opts

  if Array.isArray args
    return serial args

  args = args.split(/\s+/g)
  cmd = args.shift()
  proc = spawn cmd, args

  # echo stdout/stderr
  proc.stdout.on 'data', (data) ->
    process.stdout.write data

  proc.stderr.on 'data', (data) ->
    process.stderr.write data

  # callback on completion
  proc.on 'exit', (code) ->
    if typeof callback is 'function'
      callback null, code

exports.notify = ({icon, message, title}) ->
  icon ?= '../assets/node.ico'
  title ?= 'Die'
  spawn '../assets/notify.sh', [icon, message, title]

# Requires all the files from a directory
exports.requireAll = (dir, {exclude} = {}) ->
  exclude ?= []

  allowed = (file) ->
    for excluded in exclude
      if file == excluded or file == dir
        return false
    if /\/index\.\w+$/.test file
      return false
    true

  files = (path.join dir, file for file in fs.readdirSync dir).filter allowed
  (require file for file in files)
