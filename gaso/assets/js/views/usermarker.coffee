class Gaso.UserMarker extends Backbone.View

  constructor: (@model, @map) ->
    @model.on 'change:position', @updatePosition
    
  render: =>
    pos = @model.get 'position'
    opts =
      map: @map
      title: 'My location'
      position: new google.maps.LatLng(pos.lat, pos.lon)
      #TODO custom icon, the cool "blue dot" perhaps

    @marker = new google.maps.Marker(opts)

    return @

  updatePosition: =>
    return if not @marker?
    coords = @model.get('position')
    Gaso.log "Update user marker location", coords
    @marker.setPosition new google.maps.LatLng(coords.lat, coords.lon)  