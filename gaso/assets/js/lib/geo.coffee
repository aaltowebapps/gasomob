class GeoLib

  constructor: ->
    @geocoder = new CM.Geocoder Gaso.CM_API_KEY


  findFuelStations: (mapBounds, callback) ->

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


  latLonTogMapLatLng: (latlon) ->
    new google.maps.LatLng latlon.lat, latlon.lon if latlon?

  calculateDistanceBetween: (from, to) ->
    gTo = @latLonTogMapLatLng to
    gFrom = @latLonTogMapLatLng from
    distMeters = google.maps.geometry.spherical.computeDistanceBetween gFrom, gTo
    

# Publish our Geo-lib to application scope.
Gaso.geo = new GeoLib()
