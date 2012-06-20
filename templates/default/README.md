# {{name}}

This is the default [die] application. It demonstrates most of the basic features.

## Getting started

You can run this app multiple ways. If you already have [die] installed globally:

    die run

If you don't want to install die globally:

    npm install
    node .

## Features
-----------

### Sharing

This application can be required into other [die]/[express] apps and mounted:

    var express = require('express');
    var app = express.createServer();
    app.use('/{{name}}', require('{{name}}'));
    app.listen(3000);

[die]: https://github.com/zeekay/die
[express]: http://expressjs.com/
