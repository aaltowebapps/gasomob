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
    list = []
    mock.comments.forEach (c) ->
      co = c.toJSON()
      co.date = co.date.toISOString()
      list.push co
    callback null, list

  ###
    Create and return a callback function for handling results from our persistence layer.
    @param callback Callback function from socket.io that is called after we have data.
  ###
  syncStationsToClient: (callback) ->
    return (err, stations) ->
      return callback err if err?
      list = [];
      # TODO do another query for latest prices and append prices into stations data to return.
      stationIds = stations.map (s) -> s.id
      db.LatestPrice.searchLatestPrices stationIds, (err, prices) ->
        stations.forEach (station) ->
          stationData = station.toJSON()
          temp = prices.filter (p) -> p.id == station.id
          if temp and temp[0]
            latestStationPrices = temp[0].toJSON()
            stationData.prices = []
            for own fuelType, priceData of latestStationPrices.value
              priceObj =
                type  : fuelType
                value : priceData.price
                date  : priceData.date
              stationData.prices.push priceObj
          list.push stationData
        console.log "Sync stations to client: ", list.map (s) -> s.osmId
        callback null, list

  ###
    getStations()
    @param data Data sent from client, expected values:
      point: [lon, lat]
      radius: Number (meters)
        OR
      bounds: [[lon, lat], [lon, lat]]
        OR
      osmId: station osm-id
  ###
  getStations: (data, callback) =>
    console.log "Get stations by", data
    if data.osmId
      db.Station.findByOsmIds [data.osmId], @syncStationsToClient(callback)
    else if data.point? and data.radius?
      db.Station.findNearPoint data.point, data.radius, @syncStationsToClient(callback)
    else if data.bounds?
      db.Station.findWithin data.bounds, @syncStationsToClient(callback)
    else
      console.log "Unsupported query for stations", data
      callback "Unsupported query #{JSON.stringify(data)}"


  ###
    updateStation()
    @param data Data sent from client, expected values is a station object somewhat or exactly like our StationSchema
  ###
  updateStation: (clientdata, callback) ->
    console.log "Update station", clientdata.osmId, clientdata
    # Just ignore empty prices
    prices = clientdata.prices.filter (p) -> p.value
    console.log "Prices to save", prices

    responseSent = false
    priceSaveCallbacksProcessed = 0
    savePricesCallback = (err, data) ->
      priceSaveCallbacksProcessed++
      console.log "price save result", err, data
      unless responseSent
        if err?
          callback 'Saving of price data failed.'
          responseSent = true
        else if priceSaveCallbacksProcessed == prices.length
          callback null, "ok" 
          responseSent = true

    db.Station.findOne osmId: clientdata.osmId, (err, station) ->
      if station?
        console.log 'TODO station found from DB, handle updating of possible missing address data etc'
        station.savePrices prices, savePricesCallback
      else
        # New station
        station = new db.Station(clientdata)
        station.save (err, data) ->
          console.log "Station save result", @, err, data
          return callback 'Saving of station data failed.' if err?
          station.savePrices prices, savePricesCallback



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


