# Requires
coffeekup = require 'coffeekup'
express   = require 'express'
routes    = require './routes'
stylus    = require 'stylus'
c_assets  = require 'connect-assets'
socketio  = require 'socket.io'

# Persistence
mongoose  = require 'mongoose'
mongoose.connect('mongodb://localhost/gasodb');

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


# Sockets configuration for socket.io
io = socketio.listen app

io.sockets.on 'connection', (socket) ->
  ###
  socket.emit 'news',
    hello: 'world'
  ###

  ###
    stations:read
    Called when we .fetch() our collection in the client-side router.
  ###
  socket.on 'stations:read', (data, callback) ->
    list = [];
    console.log "Get stations by", data

    # Dummy stations
    list = [
      id: 1
      name: 'Testiasema'
      street: 'Perälänkuja 5'
      city: 'Espoo'
      zip: '00400'
      brand: 'abc'
      'location':
        'latitude': 60.167
        'longitude': 24.955
      prices:
        diesel  : 1.153
        "95E10" : 1.214
        "98E5"  : 1.375
    ,
      id: 2
      name: 'Toinen mesta'
      street: 'Usvatie 2'
      city: 'Espoo'
      zip: '00530'
      brand: 'nesteoil'
      'location':
        'latitude': 60.169696
        'longitude': 24.938536
      prices:
        diesel  : 1.123
        "95E10" : 1.234
        "98E5"  : 1.345
    ,
      id: 3
      name: 'Kolmas mesta'
      street: 'Mikäsenytolikatu 45'
      city: 'Espoo'
      zip: '00430'
      brand: 'shell'
      'location':
        'latitude': 60.16968
        'longitude': 24.945
    ]

    ###
    TODO fetch from db
    db.each 'station', (station) ->
      list.push(station._attributes);
    ###

    callback(null, list);


# Routes
app.get '/', routes.index
app.get '/templates', routes.templates

# Start app
app.listen 3000
console.log "Express server listening on port %d", app.address().port

