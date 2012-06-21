exists = require('path').existsSync
fs     = require 'fs'
{exec} = require 'child_process'

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
  if exists entry
    return entry

  for ext in extensions
    filename = entry + ext
    if exists filename
      return filename

  err = new Error "Unable to resolve path to #{entry}"
  throw err

exports.exec = (cmd) ->
  exec "npm_config_color=always #{cmd}", (err, stdout, stderr) ->
    process.stdout.write stdout
    process.stderr.write stderr

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
