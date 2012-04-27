# Couldn't come up with a better name for a business logic handling / helper controller...
class Gaso.Helper

  constructor: (@user, @stations, @searchContext) ->
    @stations.on 'add', @calculateDistance
    @user.on 'change:position', @updateDistances
    @user.on 'reCenter', @getStationsDataNearby


  calculateDistance: (station) =>
    userpos = @user.get 'position'
    # Don't do anything if user geolocation is not set.
    return if not (userpos.lat? and userpos.lon?)
    station.calculateDistanceTo userpos


  updateDistances: =>
    for station in @stations.models
      @calculateDistance station


  #TODO not used yet
  getStationsDataWithinBounds: =>
    @stations.fetch
      add : true
      data:
        bounds: @searchContext.get 'mapBounds'


  getStationsDataNearby: =>
    @stations.fetch
      add : true
      data:
        point: @user.get 'position'
        within: 10000


  findStationsWithinGMapBounds: (mapBounds) ->
    Gaso.geo.findFuelStations mapBounds, (data) =>
      addCloudmadeStationsToCollection data, @stations



  ###
    Private methods and other stuff
  ###
  addCloudmadeStationsToCollection = (data, collection) ->
    Gaso.log "CM data", data

    if data.features?
      for feature in data.features
        stationdata = feature.properties
        # Ignore stations we have already
        unless collection.get(stationdata.osm_id)?
          collection.add
            id: stationdata.osm_id
            name: stationdata.name or "Unknown"
            geoPosition:
              lat: feature.centroid.coordinates[0]
              lon: feature.centroid.coordinates[1]
    else
      Gaso.log "No 'features' in CM data", data
