class Gaso.StationMarker extends Backbone.View

  constructor: (@model, @map) ->
    # no ops

  render: =>
    pos = @model.get 'geoPosition'
    opts =
      map: @map
      title: @model.get 'name'
      position: new google.maps.LatLng(pos.lat, pos.lon)
      icon: "images/stationlogos/#{@model.get 'brand'}_50.png"

    @marker = new google.maps.Marker(opts)

    #TODO bind event listeners for handling marker InfoWindows etc
    google.maps.event.addListener(@marker, 'click', @showInfo)
    
    return @
  
  showInfo: =>  
    # TODO should we rather first show google maps info bubble and then allow user to go to refuel page from there?
    Gaso.app.router.navigate "stations/#{@model.get 'id'}", trigger: true
