class Gaso.StationMarker extends Backbone.View

  constructor: (@model, @map, @options) ->
    # no ops

  render: =>
    loc = @model.get 'location'
    opts =
      map       : @map
      title     : @model.get 'name'
      position  : new google.maps.LatLng(loc[1], loc[0])
      animation : google.maps.Animation.DROP unless @options?.noAnimation

    brand = @model.get 'brand'

    opts.icon = "images/stationlogos/#{ brand }_50.png" if brand

    @marker = new google.maps.Marker(opts)
    @bindEvents()
    
    return @

  bindEvents: ->
    google.maps.event.addListener(@marker, 'click', @showDetails)

  close: =>
    google.maps.event.clearInstanceListeners(@marker)
  
  showDetails: =>  
    Gaso.app.router.navigate "stations/#{ @model.id }", trigger: true
