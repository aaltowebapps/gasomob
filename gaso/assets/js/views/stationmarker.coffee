class Gaso.StationMarker extends Backbone.View

  constructor: (@model, @map) ->
    # no ops

  render: =>
    pos = @model.get 'geoPosition'
    opts =
      map: @map
      title: @model.get 'name'
      position: new google.maps.LatLng(pos.lat, pos.lon)

    @marker = new google.maps.Marker(opts)

    #TODO bind event listeners for handling marker InfoWindows etc
    google.maps.event.addListener(@marker, 'click', @showInfo)
    
    return @
  
  showInfo: =>  
    console.log(Gaso.app.router)
    Gaso.app.router.navigate "stations/2", trigger: true