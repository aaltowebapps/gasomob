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
  # NOTE: Deactivated appcache at least for the demo, not interested in troubleshooting this before that.
  # See layout.coffee for more ramblings.
  # app.get "/cache-#{config.env.current}.appcache", cacheManifest
