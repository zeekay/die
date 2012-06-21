class App
  el: document.getElementById 'content'

  render: ->
    @el.innerHTML = 'Welcome to {{name}}'

module.exports = new App()
