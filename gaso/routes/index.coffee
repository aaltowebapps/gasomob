config = require '../config'

###
  GET home page.
###
index = (req, res) ->
  res.render 'index'
    config: config

###
  GET templates
###
templates = (req, res) ->
  res.render 'templates'
    layout: false

touchIcon = (req, res) ->
  res.sendfile 'public/images/apple-touch-icon.png'

cacheManifest = (req, res) ->
  res.header "Content-Type", "text/cache-manifest"
  res.render 'cache'
    config: config
    layout: false

###
  Initialization.
###
exports.init = (app) ->
  app.get '/', index
  app.get '/templates', templates
  app.get '/apple-touch-icon.png', touchIcon
  app.get '/cache.appcache', cacheManifest
