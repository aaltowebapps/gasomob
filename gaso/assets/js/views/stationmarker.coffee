class Gaso.StationMarker extends Backbone.View

  # Keep a static counter to make cooler animation when adding multiple markers at once.
  counter = 0
  resetCounter = _.debounce ->
    counter = 0
  , 100

  constructor: (@model, @map, @options) ->
    # no ops

  render: =>
    loc = @model.get 'location'
    @markerOptions =
      title     : @model.get 'name'
      position  : new google.maps.LatLng(loc[1], loc[0])
      animation : google.maps.Animation.DROP unless @options?.noAnimation
      optimized : false

    # Set custom station logo
    brand = @model.get 'brand'
    if brand 
      @markerOptions.icon = new google.maps.MarkerImage "images/stationmarkers/#{ brand }_128.png",
        null # size, default ok
        null # origin, default ok
        null # anchor, default ok
        # Scaled size for retina display
        new google.maps.Size(64, 64)

    # Add the marker
    @marker = new google.maps.Marker(@markerOptions)
    @show() unless @options?.hidden

    @bindEvents()
    
    return @

  bindEvents: ->
    # Use mousedown instead of click for better tap responsiveness.
    google.maps.event.addListener(@marker, 'click', @showDetails)
    @model.on 'clear', @close

  close: =>
    @off()
    @model.off 'clear', @close
    google.maps.event.clearInstanceListeners(@marker)
    @hide()
    @map = null

  show: ->
    if @markerOptions.animation
      @timer = setTimeout @delayedAdd, counter++ * 40
    else
      @marker.setMap @map

  hide: ->
    clearTimeout @timer
    @marker.setMap null

  delayedAdd: =>
    @marker.setMap @map
    resetCounter()
  
  showDetails: => 
    Gaso.app.router.navigate "stations/#{ @model.id }", trigger: true
