app = require('die')
  base: __dirname

app.extend ->
  @get '/', ->
    @render 'layout'

module.exports = app
