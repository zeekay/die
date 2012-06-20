# die

Application and asset management to *die* for. Inspired by [hem](https://github.com/maccman/hem), [stitch](https://github.com/sstephenson/stitch), [brunch](http://brunch.io/), [flatiron](http://flatironjs.org/), [zappa](https://github.com/mauricemach/zappa), et al.

## Features

### Multi-app support
By default each app created by die is reusable by other [die]/[express] apps. Example configuration:

    die = require('die')
      base: __dirname

    app = die.createServer ->
      @use '/app2', require 'app2'
      @use '/app3', require 'app3'
      @use '/app4', require 'app4'

    module.exports = app

Each app can recursively require other apps.

## Usage
Create new project based off template:

    die new <name> [--template <template name>]

Serve project:

    die run

Build project:

    die build

The default project templates are setup for testing with [mocha](http://visionmedia.github.com/mocha/) out of the box. To run your tests:

    die test
