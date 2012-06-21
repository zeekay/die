# Die
Application and asset management to *die* for.

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

### CommonJS module support
Use CommonJS modules *in the browser* (courtesy of [Browserify][browserify]):

    class HomeView extends Backbone.View
      template: require './templates/home'
      render: ->
        @$el.html @template()
        @

Here we are requiring a [Jade][jade] template (which is compiled to an optimized function) in our [Backbone][backbone] view.

### Stylus with nib and Bootstrap baked in
Modernize your CSS with [Stylus][stylus]! [Bootstrap][bootstrap] and [nib][nib] baked in:

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

### Project Templates
Never write boilerplate code again, take advantage of Die's project templates.
Structure your projects however you like, each file in a template folder will be treated as a Mustache template
and can be passed any sort of arbitrary variables when creating a new project with `die new`. Check out the
[default templates][templates] for examples.

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

[backbone]: http://backbonejs.org/
[bootstrap]: http://twitter.github.com/bootstrap/
[browserify]: https://github.com/substack/node-browserify
[express]: http://expressjs.com/
[jade]: http://jade-lang.com/
[mocha]: https://visionmedia.github.com/mocha/
[nib]: https://github.com/visionmedia/nib
[stylus]: http://learnboost.github.com/stylus/
[templates]: https://github.com/zeekay/die/tree/master/templates
[zappa]: https://github.com/mauricemach/zappa
