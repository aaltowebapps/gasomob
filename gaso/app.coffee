# Requires
coffeekup = require 'coffeekup'
express   = require 'express'
routes    = require './routes'
stylus    = require 'stylus'
io        = require 'socket.io'
c_assets  = require 'connect-assets'

# Define global context for connect-assets
global.assets = assets = 
  js:{}, css:{}, img:{}


# Create server
app = module.exports = express.createServer()

# Configure server
app.configure ->
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'coffee'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use stylus.middleware src: "#{__dirname}/public"
  app.use app.router
  app.use express.static "#{__dirname}/public"
  
  # Define connect-assets configuration for devel
  # TODO Couldn't make connect-assets build js-files from coffeescript, we might have to build the client js manually before deployment. :/
  # Or then it just might be my windows-env, that's not working properly with connect-assets in production mode --maa
  app.use c_assets
    #src: 'assets' #default is 'assets'-folder
    helperContext: assets


# Special configuration rules for devel
app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true, showStack: true


# Special configuration rules for production
app.configure 'production', ->
  app.use express.errorHandler()


# Register CoffeeKup template-engine to Express
app.register '.coffee', coffeekup.adapters.express

# Routes
app.get '/', routes.index
app.get '/list', routes.index
app.get '/map', routes.index
app.get '/templates', routes.templates

app.listen 3000
console.log "Express server listening on port %d", app.address().port

# Socket configuration for socket.io
io = io.listen app

io.sockets.on 'connection', (socket) ->
  socket.emit 'news',
    hello: 'world'

  socket.on 'my other event', (data) ->
    console.log data
