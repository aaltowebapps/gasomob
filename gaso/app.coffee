# Requires
coffeekup = require 'coffeekup'
express = require 'express'
routes = require './routes'


# Create server
app = module.exports = express.createServer()


# Configuration


# TODO convert configuration to coffeescript
app.configure ->
  app.set('views', __dirname + '/views');
  app.set 'view engine', 'coffee'
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(require('stylus').middleware({ src: __dirname + '/public' }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
  return

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true, showStack: true
  return

app.configure 'production', ->
  app.use express.errorHandler()
  return

app.register '.coffee', coffeekup.adapters.express

# Routes
app.get '/', routes.index

app.listen 3000

console.log "Listening on 3000..."