###
Map page for a single station
###
class Gaso.StationMapPage extends Backbone.View
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-map-page'
    @setElement $('<div id="page-station-map"/>')
    @outTransition = 
      transition: 'slide'
      reverse: true
    @directionsService = new google.maps.DirectionsService()
    
  # TODO use a constructor instead
  setUser: (user) ->
    @user = user
    
  render: =>
    @$el.html @template @model.toJSON()
    @$el.attr "data-add-back-btn", "true"
    
    @directionsDisplay = new google.maps.DirectionsRenderer()
    @map = new google.maps.Map @$el.find("#station-map-canvas")[0], @getInitialMapSettings()
    @directionsDisplay.setMap @map
    @marker = new Gaso.StationMarker(@model, @map).render()
    @userMarker = new Gaso.UserMarker(@user, @map).render()
    # Don't clear listeners to allow user to come back to details page also by clicking the marker again.
    # If user for some reason comes to station page from an external link,
    # the back button could just take them away from the site.
    # google.maps.event.clearInstanceListeners(marker.marker)

    @bindEvents()

    return @

  renderDirections: =>
    start = Gaso.geo.latLonTogMapLatLng @user.get('position')
    return unless start.lat()? and start.lng()?
    end = Gaso.geo.latLonTogMapLatLng @model.getLatLng()
    request = 
      origin      : start
      destination : end
      travelMode  : google.maps.TravelMode.DRIVING
    @directionsService.route request, (result, status) =>
      if status == google.maps.DirectionsStatus.OK
        @directionsDisplay.setDirections result
    

  bindEvents: ->
    @$el.on 'pageshow.stationmappage', (event) =>
      google.maps.event.addListener @map, 'resize', =>
        Gaso.log "map resized"
        stationLoc = Gaso.geo.latLonTogMapLatLng @model.get 'location'
        @map.setCenter stationLoc
        @timer = setTimeout @renderDirections, 3000
      google.maps.event.trigger @map, 'resize'
      
      
  close: =>
    @off()
    clearTimeout @timer
    google.maps.event.clearInstanceListeners @map
    @$el.off '.stationmappage'
    @marker.close()
    @userMarker.close()


  getInitialMapSettings: =>
    zoom: 15
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: productionEnv
    
