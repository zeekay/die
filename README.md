# Die

Application and asset management to *die* for. Inspired by [Brunch][brunch], [Flatiron][flatiron], [Hem][hem], [Stitch][stitch], and [Zappa][zappa] (in no-particular order, other than alphabetical).

## Features

### Razor-sharp Express DSL
Die supports a [Zappa-ish][zappa] DSL for Express:

    die = require('die')
        base: __dirname

    app = die.createServer ->
      @set 'view options'
        layout: false

      @get '/', ->
        @render 'index'

      @get '/json', ->
        @json
          x: 1
          y: 2
          z: 3

### Client-side Jade templates
You can require [Jade][jade] templates in your client code and they will be compiled into functions requiring only the minimal Jade runtime.

    template = require 'templates/index'
    $('#user-profile').html template name: 'Tom', age: 22

### Stylus with nib and Bootstrap baked in
Modernize your CSS with [Stylus][stylus], [Bootstrap][bootstrap] and [nib][nib] baked in already!

    // everything
    @import 'bootstrap'

    // only config and forms
    @import 'bootstrap/config'
    @import 'bootstrap/forms'

    h1
      font-size 20px

### Awesome testing with Mocha
[Mocha][mocha] has emerged as the best-in-class JavaScript test framework, and Die supports it out of the box.

### Multi-app support
By default each app created by Die is reusable by other [Die][die]/[Express][express] apps. Example configuration:

    die = require('die')
      base: __dirname

    app = die.createServer ->
      @use '/app2', require 'app2'
      @use '/app3', require 'app3'
      @use '/app4', require 'app4'

    module.exports = app

Each app can of course require other apps recursively.

## Usage
Create new project based off template:

    die new <name> [--template <template name>]

Serve project (or any static assets):

    die run

Compile client-side assets (can be used independently of everything else):

    die build

Compile & watch for changes:

    die watch

Run tests:

    die test

[bootstrap]: http://twitter.github.com/bootstrap/
[brunch]: http://brunch.io/
[express]: http://expressjs.com/
[flatiron]: http://flatironjs.org/
[hem]: https://github.com/maccman/hem)
[jade]: http://jade-lang.com/
[mocha]: https://visionmedia.github.com/mocha/
[nib]: https://github.com/visionmedia/nib
[stitch]: https://github.com/sstephenson/stitch
[stylus]: http://learnboost.github.com/stylus/
[zappa]: https://github.com/mauricemach/zappa
