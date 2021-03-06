class GeoLib

  constructor: ->
    @cmGeocoder = new CM.Geocoder Gaso.CM_API_KEY
    @gooGeocoder = new google.maps.Geocoder();


  findFuelStations: (mapBounds, callback) ->

    options =
      objectType: "fuel"
      return_location: true
      boundsOnly: true
      bounds: @gMapBoundsToCMBounds mapBounds
      resultsNumber: 50

    # Run search
    @cmGeocoder.getLocations "", callback, options

  findAddress: (address, callback) ->
    @gooGeocoder.geocode address: address, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        callback null, results[0].geometry.location
      else if status == google.maps.GeocoderStatus.ZERO_RESULTS
        Gaso.fatal "Couldn't find what your were looking for. Try a different search."
      else
        Gaso.fatal "Search failed. Error code: " + status


  ###
    NOTE: Spamming getAddress() will pretty quickly get us a 'OVER_QUERY_LIMIT' error from the google maps API.
  ###
  getAddress: (location, callback) ->
    return Gaso.error "Callback is required for getAddress(loc, cb)" unless callback?

    latlng = @latLonTogMapLatLng location

    @gooGeocoder.geocode latLng: latlng, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        Gaso.log "Reverse geocoding results for address finding:", results

        address = results[0]
        if address
          # Parse results into nice format
          parts = address.formatted_address.split ','
          cityzip = parts[1].replace(/\ /g, "")
          citymatch = cityzip.match(/\D+/)
          zipmatch = cityzip.match(/\d+/)
          parsedAddress =
            country: $.trim parts[2]
            city: citymatch[0] if citymatch?
            street: $.trim parts[0]
            zip: zipmatch[0] if zipmatch?

          callback parsedAddress
        else
          Gaso.log "No address found"

      else 
        Gaso.error "Geocoder failed due to: ", status


  ###
    UTILITY METHODS related to our geo libraries and other geo stuff.
  ###
  gMapBoundsToArray: (gBounds) ->
    sw = gBounds.getSouthWest()
    ne = gBounds.getNorthEast()
    return [ [sw.lng(), sw.lat()] , [ne.lng(), ne.lat()] ]


  gMapBoundsToCMBounds: (gBounds) ->
    cmSW = @gMapLatLongToCMLatLong gBounds.getSouthWest()
    cmNE = @gMapLatLongToCMLatLong gBounds.getNorthEast()
    new CM.LatLngBounds cmSW, cmNE


  gMapLatLongToCMLatLong: (gLatLng) ->
    new CM.LatLng gLatLng.lat(), gLatLng.lng()


  latLonTogMapLatLng: (obj) ->
    if obj instanceof google.maps.LatLng
      return obj
    else if _.isArray obj
      latlon =
        lat: obj[1]
        lon: obj[0]
    else if _.isObject obj
      latlon = obj
    else
      Gaso.error "Invalid type to convert to LatLng:", obj
    new google.maps.LatLng latlon.lat, latlon.lon if latlon?

  calculateDistanceBetween: (from, to) ->
    gTo = @latLonTogMapLatLng to
    gFrom = @latLonTogMapLatLng from
    distMeters = google.maps.geometry.spherical.computeDistanceBetween gFrom, gTo
    

# Publish our Geo-lib to application scope.
Gaso.geo = new GeoLib()
