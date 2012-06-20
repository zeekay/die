# {{name}}

This is a [die](https://github.com/zeekay/die) application. It demonstrates only the most basic features.

## Getting started

You can run this app multiple ways. If you already have [die](https://github.com/zeekay/die) installed globally:

    die run

If you don't want to install die globally:

    npm install
    node .

## Features
-----------

### Sharing
This application can be required into other die/express apps and mounted:

    var express = require('express');
    var app = express.createServer();
    app.use('/{{name}}', require('{{name}}'));
    app.listen(3000);
