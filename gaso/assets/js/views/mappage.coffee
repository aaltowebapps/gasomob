###
Map page
###
class Gaso.MapPage extends Backbone.View

  stationMarkers: []

  constructor: (@stations, @user) ->
    @template = _.template Gaso.util.getTemplate 'map-page'

    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-map"/>')


  render: =>
    @$el.html @template @stations.toJSON()

    @geocoder = new CM.Geocoder Gaso.CM_API_KEY
    @map = new google.maps.Map @$el.find("#map-canvas")[0], @getInitialMapSettings()
    # Bind some events
    google.maps.event.addListener @map, 'dragend', =>
      @saveMapLocation()
      # FIXME now we trigger a search to Cloudmade every time map moves, which might be a bit too greedy, modify?
      @findNearbyStations()

    # New marker for user position as View.
    new Gaso.UserMarker(@user, @map).render()

    # New markers for stations.
    for station in @stations.models
      @addStationMarker station

    @bindEvents()

    return @

  bindEvents: ->
    Gaso.log "Bind events to", @
    # Bind events

    # Redraw map on jQM page change, otherwise it won't fill the screen.
    ###
     TODO the transition between pages here is still clunky. Maybe we could force
     gMaps to draw initial map larger instead of the small box
     in the top-left corner of the screen?
    ###
    @$el.off 'pageshow.mapppage'
    @$el.on 'pageshow.mappage', (event) =>
      Gaso.log "Resize map"
      google.maps.event.trigger @map, 'resize'

    @stations.on 'add', @addStationMarker
    # TODO handle station remove
    @user.on 'reCenter', @changeMapLocation

  close: =>
    @off()
    @stations.off 'add', @addStationMarker
    @user.off 'reCenter', @changeMapLocation

  getInitialMapSettings: =>
    coords = @user.get 'mapCenter'
    # return object in google.maps options format, see https://developers.google.com/maps/documentation/javascript/reference#MapOptions
    center: new google.maps.LatLng(coords.lat, coords.lon)
    zoom: @user.get 'mapZoom'
    mapTypeId: google.maps.MapTypeId[@user.get 'mapTypeId']


  changeMapLocation: =>
    coords = @user.get 'mapCenter'
    Gaso.log "Pan map to", coords
    @map.panTo new google.maps.LatLng(coords.lat, coords.lon)
    @findNearbyStations()


  saveMapLocation: =>
    currCenter = @map.getCenter()
    @user.set 'mapCenter'
      lat: currCenter.lat()
      lon: currCenter.lng()
    @user.save()


  addStationMarker: (station) =>
    @stationMarkers.push new Gaso.StationMarker(station, @map).render()


  findNearbyStations: =>
    Gaso.log "Find nearby stations"

    mapBounds = @map.getBounds()
    #Try again after a moment if map is not yet ready.
    if not mapBounds?
      setTimeout =>
        @findNearbyStations()
      , 2000
      return

    options =
      objectType: "fuel"
      boundsOnly: true
      bounds: @mapBoundsToCMBounds mapBounds
      resultsNumber: 20

    processResponse = (response) =>
      Gaso.log "CM response", response

      if response.features?
        for feature in response.features
          stationdata = feature.properties
          # Ignore stations we have already
          if not @stations.get(stationdata.osm_id)?
             # Ignore stations that don't have name set in OSM data.
             if stationdata.name
              @stations.add
                id: stationdata.osm_id
                name: stationdata.name
                geoPosition:
                  lat: feature.centroid.coordinates[0]
                  lon: feature.centroid.coordinates[1]
      else
        Gaso.log "No 'features' in CM response", response

    # Run search
    @geocoder.getLocations "", processResponse, options


  mapBoundsToCMBounds: (gBounds) =>
    cmSW = @mapLatLongToCMLatLong gBounds.getSouthWest()
    cmNE = @mapLatLongToCMLatLong gBounds.getNorthEast()
    new CM.LatLngBounds cmSW, cmNE

  mapLatLongToCMLatLong: (gLatLng) =>
    new CM.LatLng gLatLng.lat(), gLatLng.lng()
