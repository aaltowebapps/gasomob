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
        point: latlng
        within: Number (meters)
          OR
        bounds: latlng, latlng

    ###
    socket.on 'stations:read', (data, send) ->
      list = [];
      console.log "Get stations by", data

      # now returning mock data, do real geospatial query by query data
      db.Station.findByOsmIds [1,2,3], (err, result) ->
          # TODO first fetch latest prices for stations and append that to data to return.
        result.forEach (station) ->
          list.push station.toJSON()
        send(null, list);



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


      gotResult = (stationInDB) ->
        console.log "found", stationInDB
        unless stationInDB?

          # Do some conversions
          data.osmId = data.id unless data.osmId?
          delete data.id
          data.location = 
            # NOTE: order must be lon, lat! (ie. x, y)
            lon: data.geoPosition.lon
            lon: data.geoPosition.lat
          delete data.geoPosition
          delete data.prices
          delete data.directDistance
          delete data.drivingDistance


          new db.Station(data).save stationSaved 
        else
          console.log 'TODO station found from DB, handle update'

      # TODO save prices
      #db.FuelPrice.getTypes().forEach (val) ->

      db.Station.find {osmId: data.id}, gotResult

    ###
      station:create
      Called when we .save() a new station model on client-side.
    ###
    socket.on 'station:create', (data, callback) ->
      console.log "Create station", data


    socket.on 'disconnect', (data) ->
      console.log "User left", data
      usercount--
