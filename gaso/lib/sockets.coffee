# Sockets configuration for socket.io
socketio = require 'socket.io'
mock = require '../test/mockdata'

exports.init = (app) ->
  console.log "Initialize socket listening"

  io = socketio.listen app

  io.sockets.on 'connection', (socket) ->
    ###
      COLLECTIONS RELATED
    ###

    ###
      stations:read
      Called when we .fetch() our collection in the client-side router.
    ###
    socket.on 'stations:read', (data, callback) ->
      list = [];
      console.log "Get stations by", data

      list = mock.stations

      ###
      TODO fetch from db
      db.each 'station', (station) ->
        list.push(station._attributes);
      ###

      callback(null, list);

    ###
      stations:update
      Called when we .save() our collection on client-side.
    ###
    socket.on 'stations:update', (data, callback) ->
      console.log "Update stations", data


    ###
      MODEL RELATED
    ###

    ###
      station:update
      Called when we .save() our existing station model on client-side, if the model has own url-property defined to 'station'.
    ###
    socket.on 'station:update', (data, callback) ->
      console.log "Update station", data.id, data

    ###
      station:create
      Called when we .save() our existing station model on client-side.
    ###
    socket.on 'station:create', (data, callback) ->
      console.log "Create station", data
