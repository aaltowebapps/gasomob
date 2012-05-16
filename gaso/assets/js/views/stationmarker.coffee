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
    opts =
      title     : @model.get 'name'
      position  : new google.maps.LatLng(loc[1], loc[0])
      animation : google.maps.Animation.DROP unless @options?.noAnimation
      optimized : false

    # Set custom station logo
    brand = @model.get 'brand'
    if brand 
      opts.icon = new google.maps.MarkerImage "images/stationmarkers/#{ brand }_128.png",
        null # size, default ok
        null # origin, default ok
        null # anchor, default ok
        # Scaled size for retina display
        new google.maps.Size(64, 64)

    # Add the marker
    @marker = new google.maps.Marker(opts)
    if opts.animation
      setTimeout @delayedAdd, counter++ * 40
    else
      @marker.setMap @map

    @bindEvents()
    
    return @

  bindEvents: ->
    google.maps.event.addListener(@marker, 'click', @showDetails)

  close: =>
    google.maps.event.clearInstanceListeners(@marker)


  delayedAdd: =>
    @marker.setMap @map
    resetCounter()
  
  showDetails: =>  
    Gaso.app.router.navigate "stations/#{ @model.id }", trigger: true
