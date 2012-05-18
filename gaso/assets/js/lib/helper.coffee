# Couldn't come up with a better name for a business logic handling / helper controller...
class Gaso.Helper

  constructor: (@user, @stations, @searchContext) ->
    # @stations.on 'add', @setDistanceToUser
    @user.on 'change:position', @updateStationDistancesToUser
    @user.on 'reCenter', @getStationsDataNearby


  calculateDistanceToUser: (loc) =>
    userpos = @user.get 'position'
    # Don't do anything if user geolocation is not set.
    return if not (userpos.lat? and userpos.lon?)
    distMeters = Gaso.geo.calculateDistanceBetween userpos, loc
    distFloat = (distMeters / 1000).toFixed(1)


  setDistanceToUser: (station) =>
    dist = @calculateDistanceToUser station.get 'location'
    station.set 'directDistance', dist


  updateStationDistancesToUser: =>
    for station in @stations.models
      dist = @setDistanceToUser station

  findStationByOsmId: (osmId, callback) =>
    @stations.fetch
      add: true
      data:
        osmId: osmId
      success: (collection, response) ->
        callback null, response
      error: (collection, response) ->
        callback response

  getStationsDataWithinBounds: (bounds) =>
    @stations.fetch
      add : true
      data:
        bounds: bounds

  getStationsDataNearby: =>
    userpos = @user.get 'position'
    @stations.fetch
      add : true
      data:
        point: [userpos.lon, userpos.lat]
        radius: 10

  findStationsWithinGMapBounds: (mapBounds) ->
    @getStationsDataWithinBounds Gaso.geo.gMapBoundsToArray mapBounds
    Gaso.geo.findFuelStations mapBounds, (data) =>
      convertCMDatatoStationData data, (station) =>
        @addStationToCollection station, update: false


  addStationToCollection: (stationData, options) =>
    defaults =
      update: true
    settings = _.extend {}, defaults, options
    existingModel = @stations.get stationData.osmId

    if existingModel?
      if settings.update
        Gaso.log "TODO update station model with possible new/extra data we don't have yet"
    else
      # Calculate direct distance to user before adding to collection.
      # This way we avoid extra re-renderings and make collection sort initially better.
      station = new Gaso.Station(stationData)
      @setDistanceToUser station
      @stations.add station

  message: (msg, options) =>
    new Gaso.FeedbackMessage(msg, options).render()

  ###
    Private methods and other stuff
  ###
  convertCMDatatoStationData = (data, conversionCallback) ->
    Gaso.log "CM data", data

    if data.features?
      for feature in data.features
        stationdata = feature.properties
        
        # Address data might be missing completely for many stations, but lets use it if it exists.
        sStreet = stationdata['addr:street']
        sNum = stationdata['addr:housenumber']

        newStation =
          osmId: stationdata.osm_id
          name: stationdata.name or "Unknown"
          address: {
            street: "#{sStreet} #{sNum}" if sNum and sStreet
            city: stationdata['addr:city']
            zip: stationdata['addr:postcode']
            country: stationdata['addr:country']
          }
          location: [
            # centroid is in the order [lat, lon], we require [lon, lat].
            feature.centroid.coordinates[1] 
            feature.centroid.coordinates[0]
          ]
        
        conversionCallback newStation
    else
      Gaso.log "No 'features' in CM data", data
