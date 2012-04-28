# Sockets configuration for socket.io
socketio = require 'socket.io'
mock = require '../dev/mockdata'

db = require './persistence'

# TODO Testing listening events from mongoose models
db.Station.on 'save', (arg1, arg2) ->
  console.log "Sockets listening station saved", @, arg1, arg2

usercount = 0

exports.init = (app) ->
  console.log "Initialize socket listening"

  io = socketio.listen app

  io.sockets.on 'connection', (socket) ->
    usercount++

    ###
      COLLECTIONS RELATED
    ###

    ###
      stations:read
      Called when we .fetch() our collection in the client-side router.
      @param data Data sent from client, expected values:
        point: [lon, lat]
        radius: Number (meters)
          OR
        bounds: [[lon, lat], [lon, lat]]

    ###
    socket.on 'stations:read', (data, callback) ->
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
      prices = data.prices

      # TODO make this more readable, now order turned upside down

      stationSaved = (err, data) ->
        console.log "Station saved", @, err, data


      findCallback = (err, stationInDB) ->
        console.log "found", stationInDB
        unless stationInDB.length
          new db.Station(data).save stationSaved 
        else
          console.log 'TODO station found from DB, handle update'

      # TODO save prices
      #db.FuelPrice.getTypes().forEach (val) ->

      db.Station.find {osmId: data.osmId}, findCallback

    ###
      station:create
      Called when we .save() a new station model on client-side.
    ###
    socket.on 'station:create', (data, callback) ->
      console.log "Create station", data


    socket.on 'disconnect', (data) ->
      console.log "User left", data
      usercount--
