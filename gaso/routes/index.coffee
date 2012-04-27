config = require '../config'

###
  GET home page.
###
index = (req, res) ->
  res.render 'index'
    config: config
  return

###
  GET templates
###
templates = (req, res) ->
  res.render 'templates'
    layout: false
  return

touchIcon = (req, res) ->
  res.sendfile 'public/images/apple-touch-icon.png'

###
  Initialization.
###
exports.init = (app) ->
  app.get '/', index
  app.get '/templates', templates
  app.get '/apple-touch-icon.png', touchIcon
