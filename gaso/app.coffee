config  = require './config'
express = require 'express'


# Create and configure server.
app = module.exports = express.createServer()
require('./config/environment').configure app


# Init websockets.
require('./lib/sockets').init app


# Define normal routes.
routes = require './routes'
app.get '/', routes.index
app.get '/templates', routes.templates


# Define REST API.
rest = require './routes/restapi'
# TODO


# Start server.
console.log "Start server..."
app.listen config.server.port
console.log "Express server listening on port %d", app.address().port

