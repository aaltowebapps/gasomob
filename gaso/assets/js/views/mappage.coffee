###
Map page
###
class Gaso.MapPage extends Backbone.View


  constructor: (@stations, @user) ->
    @stationMarkers = []
    @template = _.template Gaso.util.getTemplate 'map-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-map"/>')
    @mapReady = false


  render: =>
    @$el.html @template @stations.toJSON()

    @map = new google.maps.Map @$el.find("#map-canvas")[0], @getInitialMapSettings()

    # New marker for user position as View.
    @initialCenter = @user.get 'mapCenter'
    @userMarker = new Gaso.UserMarker(@user, @map).render()

    # New markers for stations.
    for station in @stations.models
      @addStationMarker station

    @bindEvents()

    return @
    

  bindEvents: ->
    Gaso.log "Bind events to", @

    # Save new zoom level to user model when map zoom has changed.
    google.maps.event.addListener @map, 'zoom_changed', _.debounce =>
      prevZoom = @user.get 'mapZoom'
      newZoom = @map.getZoom()
      Gaso.log "Zoom level set to", newZoom
      @user.set 'mapZoom', newZoom
      @user.save()
    , 300

    # Save new location and fetch stations when map bounds change.
    google.maps.event.addListener @map, 'bounds_changed', _.debounce =>
      if Gaso.loggingEnabled()
        Gaso.log "Map bounds changed to", @map.getBounds()?.toString()
        @saveMapLocation()
        @findNearbyStations()
    , 300

    @$el.on 'pagebeforehide.mappage', (event) =>
      # Transition from the map page caused new map center to be saved incorrectly during/right after
      # the transition.
      @mapReady = false
    

    # Redraw map on jQM page change, otherwise it won't fill the screen.
    @$el.on 'pageshow.mappage', (event) =>
      Gaso.log "Resize map on jQM 'pageshow'"
      google.maps.event.trigger @map, 'resize'
      @mapReady = true
      # return object in google.maps options format, see https://developers.google.com/maps/documentation/javascript/reference#MapOptions
      if @initialCenter?
        @map.setCenter new google.maps.LatLng(@initialCenter.lat, @initialCenter.lon)
      @findNearbyStations()
  
    @stations.on 'add', @addStationMarker
    # TODO handle station remove
    @user.on 'reCenter', @changeMapLocation

  close: =>
    google.maps.event.clearInstanceListeners @map
    @off()
    @$el.off '.mappage'
    @stations.off 'add', @addStationMarker
    @user.off 'reCenter', @changeMapLocation
    @userMarker.close()
    for marker in @stationMarkers
      marker.close()

  getInitialMapSettings: =>
    zoom: @user.get 'mapZoom'
    mapTypeId: google.maps.MapTypeId[@user.get 'mapTypeId']
    disableDefaultUI: productionEnv

  changeMapLocation: =>
    coords = @user.get 'mapCenter'
    Gaso.log "Pan map to", coords
    @map.panTo new google.maps.LatLng(coords.lat, coords.lon)


  saveMapLocation: =>
    return if not @mapReady
    currCenter = @map.getCenter()
    if Gaso.loggingEnabled()
      Gaso.log "Save map location", currCenter.toString()
    @user.set 'mapCenter'
      lat: currCenter.lat()
      lon: currCenter.lng()
    @user.save()


  addStationMarker: (station) =>
    @stationMarkers.push new Gaso.StationMarker(station, @map).render()


  findNearbyStations: =>
    return if not @mapReady
    mapBounds = @map.getBounds()

    #Try again after a moment if map is not yet ready.
    if not mapBounds?
      setTimeout =>
        @findNearbyStations()
      , 2000
      return


    # Don't look for nearby stations if
    # - user has zoomed too far out
    # - new bounds are completely within the bounds where we searched last time.
    if @user.get('mapZoom') >= 7
      if @isBoundsFromNewArea mapBounds
        if Gaso.loggingEnabled()
          Gaso.log "Find stations within", mapBounds?.toString()
        Gaso.helper.findStationsWithinGMapBounds mapBounds
    else
      Gaso.log "Zoomed too far out, not fetching stations"


  isBoundsFromNewArea: (newBounds) =>
    oldBounds = @latestSearchBounds

    unless oldBounds?
      @latestSearchBounds = newBounds
      return true

    unless oldBounds.contains newBounds.getSouthWest() 
      @latestSearchBounds = newBounds
      return true

    unless oldBounds.contains newBounds.getNorthEast()
      @latestSearchBounds = newBounds
      return true

    Gaso.log "New map bounds are within previous search bounds. Won't do a new search for stations."
    return false
