###
Station
###
class Gaso.Station extends Backbone.Model
  noIoBind: false
  socket: window.socket

  brand: ''
  name:  ''

  location:
  	lat: 0
  	lon: 0

  prices:
  	diesel: 0
  	E10: 0
  	octane_98: 0
 
  services:
  	air: true
  	store: true


  initialize: (stationData) ->
    @markerOptions = {}
    @markerOptions.position = new google.maps.LatLng(stationData.location['latitude'], stationData.location['longitude'])
    @markerOptions.title = stationData.name


  cleanup: ->
    @ioUnbindAll()
    return @