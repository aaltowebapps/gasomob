config  = require './config'
express = require 'express'


# Create and configure server.
app = module.exports = express.createServer()
require('./config/environment').configure app

# Init websockets communication.
require('./lib/sockets').init app
# Setup normal routes.
require('./routes').init app
# Define and setup REST API.
require('./routes/restapi').init app


# Start server.
console.log "Start server..."
app.listen config.server.port
console.log "Express server listening on port %d", config.server.port

