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

  events:
    'tap #center-user' : 'onCenterToUser'

  render: =>
    @$el.html @template @stations.toJSON()

    Gaso.log "Render new Google Map"
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

    # Save new location and fetch stations when map bounds change.
    google.maps.event.addListener @map, 'bounds_changed', _.debounce =>
      Gaso.log "Map bounds changed to", @map.getBounds()?.toString() if Gaso.loggingEnabled()
      @saveZoomLevel()
      @saveMapLocation()
      @findNearbyStations()
    , 300

    @$el.on 'pagebeforehide.mappage', (event) =>
      # Transition from the map page caused new map center to be saved incorrectly during/right after
      # the transition. Therefore set the flag to false before transition begins.
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
    zoom             : @user.get 'mapZoom'
    mapTypeId        : google.maps.MapTypeId[@user.get 'mapTypeId']
    disableDefaultUI : productionEnv
    mapTypeControl   : false

  onCenterToUser: (event) ->
    event.preventDefault()
    @user.set 'mapCenter', @user.get('position')
    @changeMapLocation()

  changeMapLocation: =>
    coords = @user.get 'mapCenter'
    Gaso.log "Pan map to", coords
    @map.panTo new google.maps.LatLng(coords.lat, coords.lon)

  saveZoomLevel: =>
    prevZoom = @user.get 'mapZoom'
    newZoom = @map.getZoom()
    if prevZoom != newZoom
      Gaso.log "Zoom level changed to", newZoom
      @user.set 'mapZoom', newZoom
      @user.save()

  saveMapLocation: =>
    return if not @mapReady
    currCenter = @map.getCenter()
    Gaso.log "Save map location", currCenter.toString() if Gaso.loggingEnabled()
    @user.set 'mapCenter'
      lat: currCenter.lat()
      lon: currCenter.lng()
    @user.save()


  addStationMarker: (station) =>
    @stationMarkers.push new Gaso.StationMarker(station, @map, hidden: @markersHidden).render()

  temporarilyHideMarkers: =>
    unless @markersHidden
      for m in @stationMarkers
        m.hide()
      @markersHidden = true

  showMarkers: =>
    if @markersHidden
      for m in @stationMarkers
        m.show()
      @markersHidden = false

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
    # Don't use the zoom level, because it is dependent on the display resolution?
    # if @user.get('mapZoom') >= 12
    # Instead we calculate the diameter between displayed map corners.
    mapBoundsDiameter = Gaso.geo.calculateDistanceBetween(mapBounds.getSouthWest(), mapBounds.getNorthEast())
    Gaso.log "Map bounds diameter", mapBoundsDiameter
    if mapBoundsDiameter < 30000
      @showMarkers()
      if @isBoundsFromNewArea mapBounds
        # @zoomFeedback?.instantRemove()
        Gaso.log "Find stations within", mapBounds?.toString() if Gaso.loggingEnabled()
        Gaso.helper.findStationsWithinGMapBounds mapBounds
    else
      @temporarilyHideMarkers()
      @zoomFeedback = Gaso.helper.message "Zoom in closer to search nearby stations.", replace: true
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
