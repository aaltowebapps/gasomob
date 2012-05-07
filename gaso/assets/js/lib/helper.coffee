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
    stationLoc = station.getLatLng()
    return if not (stationLoc.lat? and stationLoc.lon?)
    distMeters = Gaso.geo.calculateDistanceBetween userpos, stationLoc
    station.set 'directDistance', (distMeters / 1000).toFixed(1)


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
    userpos = @user.get 'position'
    @stations.fetch
      add : true
      data:
        point: [userpos.lon, userpos.lat]
        radius: 10


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
            osmId: stationdata.osm_id
            name: stationdata.name or "Unknown"
            # What are these? There's no address data readily in CM response afaik. --Markus
            #street: stationdata['addr:street'].concat " ", stationdata['addr:housenumber']
            #city: stationdata['addr:city']
            #zip: stationdata['addr:postcode']
            location: [
              # centroid is in the order [lat, lon], we require [lon, lat].
              feature.centroid.coordinates[1] 
              feature.centroid.coordinates[0]
            ]
    else
      Gaso.log "No 'features' in CM data", data
