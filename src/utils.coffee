{exec} = require 'child_process'

exports.flatten = flatten = (array, results = []) ->
  for item in array
    if Array.isArray(item)
      flatten(item, results)
    else
      results.push(item)
  results

exports.toArray = (value = []) ->
  if Array.isArray(value) then value else [value]

exports.exec = (args) ->
  exec args, (err, stdout, stderr) ->
    console.log stdout
    console.error stderr

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
