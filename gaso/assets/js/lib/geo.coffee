class Geo

  constructor: ->
    @geocoder = new CM.Geocoder Gaso.CM_API_KEY


  findFuelStations: (mapBounds, callback) =>

    options =
      objectType: "fuel"
      boundsOnly: true
      bounds: @gMapBoundsToCMBounds mapBounds
      resultsNumber: 20

    # Run search
    @geocoder.getLocations "", callback, options


  ###
    UTILITY METHODS related to our geo libraries and other geo stuff.
  ###

  gMapBoundsToCMBounds: (gBounds) ->
    cmSW = @gMapLatLongToCMLatLong gBounds.getSouthWest()
    cmNE = @gMapLatLongToCMLatLong gBounds.getNorthEast()
    new CM.LatLngBounds cmSW, cmNE


  gMapLatLongToCMLatLong: (gLatLng) ->
    new CM.LatLng gLatLng.lat(), gLatLng.lng()



Gaso.geo = new Geo()
