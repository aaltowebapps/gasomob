# Sockets configuration for socket.io
socketio = require 'socket.io'
mock = require '../dev/mockdata'

db = require './persistence'


class Sync

  constructor: (socket) ->
    socket.on 'comments:read', @getComments

    # stations:read is called when we .fetch() our collection in the client-side router.
    socket.on 'stations:read', @getStations

    # station:update is called when we .save() our existing station model on client-side, 
    # when the model has own url-property defined to 'station'. (If it didn't, the event would be stations:update.)
    socket.on 'station:update', @updateStation

    # station:create is called when we .save() a new station model that doesn't have an id yet on client-side.
    socket.on 'station:create', @createStation

  getComments: (data, callback) ->
    console.log "Get comments by", data
    list = mock.comments;
    callback(null, list)

  ###
    getStations()
    @param data Data sent from client, expected values:
      point: [lon, lat]
      radius: Number (meters)
        OR
      bounds: [[lon, lat], [lon, lat]]
  ###
  getStations: (data, callback) ->
    list = [];
    console.log "Get stations by", data


    if data.point?

      # MongoDB $near queries can be done in array form [lon, lat, distance_in_radians]
      near = data.point
      # Divide radius by average earth radius to get radians.
      near.push data.radius / 6371

      # TODO Simplify interface by moving actual query to some common model library
      # TODO what's wrong with spatial queries, not getting results...?
      # mongo: db.stations.find({"location": {"$near" : [24.93824, 60.169812, 10/6371], }})
      # n = 10
      # coffee: db.Station.find location: $near: [24.93824, 60.169812, n/6371], (err, docs) -> console.log docs
      console.log "find near", near
      db.Station.find
        location:
          $nearSphere: near
        (err, result) ->
          return callback err if err?
          # TODO do another query for latest prices and append prices into stations data to return.
          console.log "Query result", err, result
          result.forEach (station) ->
            list.push station.toJSON()
          console.log "callback stations to client: ", list.map (s) -> s.osmId
          callback(null, list)
    else if data.bounds?
      console.log 'TODO do geospatial query of stations by bounds'
    else
      console.log "Unsupported query for stations", data
      callback "Unsupported query #{data}"


  ###
    updateStation()
    @param data Data sent from client, expected values is a station object somewhat or exactly like our StationSchema
  ###
  updateStation: (clientdata, callback) ->
    console.log "Update station", clientdata.osmId, clientdata
    prices = clientdata.prices

    db.Station.findOne osmId: clientdata.osmId, (err, station) ->
      if station?
        console.log 'TODO station found from DB, handle update'
        # TODO save non-zero prices of each type if latest price isn't equal to the price being saved already
      else
        # New station
        station = new db.Station(clientdata)

      station.save (err, data) ->
        # TODO save non-zero prices
        console.log "Station saved", @, err, data


  ###
    createStation()
  ###
  createStation: (data, callback) ->
    console.log "Create station", data



usercount = 0
onConnect = (socket) ->
  usercount++

  new Sync(socket)

  socket.on 'disconnect', ->
    usercount--
    console.log "User left. User count", usercount


exports.init = (app) ->
  console.log "Initialize socket listening"

  io = socketio.listen app

  io.configure 'production', ->
    io.enable 'browser client minification'  # send minified client
    io.enable 'browser client etag'          # apply etag caching logic based on version number
    io.enable 'browser client gzip'          # gzip the file
    io.set 'log level', 1                    # reduce logging

    # enable all transports
    io.set 'transports', [
      'websocket'
      'flashsocket'
      'htmlfile'
      'xhr-polling'
      'jsonp-polling'
    ]

  io.sockets.on 'connection', onConnect


