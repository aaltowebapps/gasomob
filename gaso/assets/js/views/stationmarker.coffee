class Gaso.StationMarker extends Backbone.View

  constructor: (@model, @map) ->
    # no ops

  render: =>
    loc = @model.get 'location'
    opts =
      map       : @map
      title     : @model.get 'name'
      position  : new google.maps.LatLng(loc[1], loc[0])
      animation : google.maps.Animation.DROP

    brand = @model.get 'brand'

    opts.icon = "images/stationlogos/#{ brand }_50.png" if brand

    @marker = new google.maps.Marker(opts)

    #TODO bind event listeners for handling marker InfoWindows etc
    google.maps.event.addListener(@marker, 'click', @showInfo)
    
    return @

  close: =>
    #TODO remove map event listeners
  
  showInfo: =>  
    # TODO should we rather first show google maps info bubble and then allow user to go to refuel page from there?
    Gaso.app.router.navigate "stations/#{ @model.id }", trigger: true
