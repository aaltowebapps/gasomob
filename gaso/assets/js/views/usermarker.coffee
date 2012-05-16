class Gaso.UserMarker extends Backbone.View

  constructor: (@model, @map) ->
  
  render: =>
    @renderLocationIndicator()
    @renderAccuracyIndicator()
    @bindEvents()
    return @

  bindEvents: =>
    @model.on 'change:position change:positionAccuracy', @updatePosition

  close: =>
    @model.off 'change:position change:positionAccuracy', @updatePosition

  renderLocationIndicator: =>
    pos = @model.get 'position'

    image = new google.maps.MarkerImage 'images/blue_ball32.png',
      # Marker size
      null
      # The origin for this image is 0,0. (i.e. we could use a icon-sprite-file and define another origin point)
      new google.maps.Point(0, 0)
      # The anchor for this image is the center of the ball.
      new google.maps.Point(8, 8)
      # Scaled size
      new google.maps.Size(16, 16)

    opts =
      map: @map
      title: "My location#{if not @getCircleRadius()? then ' (inaccurate)' else ''}"
      position: new google.maps.LatLng(pos.lat, pos.lon)
      icon: image
      animation: google.maps.Animation.DROP
      # Added option for using Retina-optimized icons, see
      # http://stackoverflow.com/questions/9208916/google-map-custom-markers-retina-resolution
      optimized: false

    @marker = new google.maps.Marker(opts)


  renderAccuracyIndicator: =>
    pos = @model.get 'position'

    opts =
      map: @map
      strokeColor: "#33a3f3"
      strokeOpacity: 0.6
      strokeWeight: 1
      fillColor: "#33a3f3"
      fillOpacity: 0.3
      center: new google.maps.LatLng(pos.lat, pos.lon)
      radius: @getCircleRadius()

    @circle = new google.maps.Circle(opts)


  updatePosition: =>
    return if not @marker?
    coords = @model.get('position')
    Gaso.log "Update user marker location", coords
    newPos = new google.maps.LatLng(coords.lat, coords.lon)
    # Update location marker
    @marker.setPosition newPos
    # Update accuracy circle
    @circle.setCenter newPos
    @circle.setRadius @getCircleRadius()


  getCircleRadius: =>
    # Don't display accuracy circle at all, if location is not accurate enough.
    if @model.isPositionAccurate() then @model.get 'positionAccuracy' else null
