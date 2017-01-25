## Introduction

[![Greenkeeper badge](https://badges.greenkeeper.io/zeekay/die.svg)](https://greenkeeper.io/)

Die is a framework for building reusable JavaScript applications. It can be used to build anything
from a single-page application to a full stack web application framework. Die does it's best to stay out
of your way, allowing you the utmost in control over your application.

Use the defaults or just what you need and build whatever you want.

## Features

### Razor-sharp DSL for Express
Die supports a [Zappa-ish][zappa] DSL for [Express][express] making the already fast process
of building [Node.js][node] server applications with [Express][express] even faster!

```javascript
app = require('die')({
    base: __dirname
});

app.extend(function(){
    this.get('/', function(){
        this.render('index');
    });
});
```

Or even more succintly with [CoffeeScript][coffee]:

```coffeescript
app = require('die')
    base: __dirname

app.extend ->
  @get '/', -> @render 'index'
```

### Share code between client and server
JavaScript is an [isomorphic language][isomorphic], which means it can execute on both the client
and server. Die lets you leverage this by allowing you to organize your code into [Node.js][node]
compatible [modules][modules].

```javascript
var HomeView = Backbone.View.extend({
  // Require another module (a compiled template) in to your Backbone view.
  template: require('./templates/home'),
  render: function() {
    $(this.el).html(this.template())
    return this;
  }
}

// Export your view so that it can be used from other modules.
module.exports = HomeView
```

Die uses [Requisite][requisite] to package up your client code, resolving dependencies, and bundling
 everything together for you automatically.

### Stylus with nib and Bootstrap baked in
Modernize your CSS with [Stylus][stylus]! [Bootstrap][bootstrap] and [nib][nib] baked in:

```css
// everything
@import 'bootstrap'

// only config and forms
@import 'bootstrap/config'
@import 'bootstrap/forms'

h1
  font-size 20px
```

### Awesome testing with Mocha
[Mocha][mocha] has emerged as a best-in-class JavaScript testing framework, and Die supports it out
of the box.

### Multi-app support
By default each app created by Die is reusable by other Die/[Express][express] apps. Example
configuration:

```javascript
// Add app2's static paths to the stack, make client-side code available.
app.inject(app2);

// Mount app3 in it's entirety at /app3
app.mount('/app3', app3);
```

Each app can of course require other apps recursively.

### Project Templates
Never write boilerplate code again, take advantage of Die's project templates.
Structure your projects however you like, each file in a template folder will be treated as a
Mustache template and can be passed any sort of arbitrary variables when creating a new project
with `die new`. Check out the [default templates][templates] for examples.

## Usage
Create new project based off template:

```bash
die new <name> [--template <template name>, --install, --production]
```

Serve project (or just static files):

```bash
die run
```

Compile client-side assets:

```bash
die build
```

Can also be used to build stand-alone CSS and JavaScript assets:

```bash
die build --minify --css [in] --css-path [out] --js [in] --js-path [out]
```

Compile & watch client-side assets, recompiling on change:

```bash
die watch
```

Run tests:

```bash
die test
```

[backbone]: http://backbonejs.org
[bootstrap]: http://twitter.github.com/bootstrap
[coffee]: http://coffeescript.org
[express]: http://expressjs.com
[isomorphic]: blog.nodejitsu.com/scaling-isomorphic-javascript-code
[jade]: http://jade-lang.com
[mocha]: https://visionmedia.github.com/mocha
[modules]: http://nodejs.org/api/modules.html
[nib]: https://github.com/visionmedia/nib
[node]: http://nodejs.org
[requisite]: http://requisitejs.org
[stylus]: http://learnboost.github.com/stylus
[templates]: https://github.com/zeekay/die/tree/master/templates
[zappa]: https://github.com/mauricemach/zappa

## Development

Before you can hack on die you need to:

* Clone your forks of [Requisite][requisite] and die in the same parent folder

* Set up [Requisite][requisite]
  * `cd requisite/; npm install && cake build`

* Set up die
  * `cd../die/; git branch develop; git co develop`
  * `npm install && npm link ../requisite && cake build`
