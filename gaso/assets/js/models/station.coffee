###
Station
###
class Gaso.Station extends Backbone.Model
  noIoBind: false
  socket: window.socket

  defaults:
    brand: ''
    name:  ''

    street: ''
    city: ''
    zip: ''

    geoPosition:
    	lat: 0
    	lon: 0

    prices:
    	diesel: 0
    	"95E10": 0
    	"98E5": 0
   
    services:
    	air: true
    	store: true


  initialize: (stationData) ->
    @set 'id', stationData.id
    pos = 
      lat: stationData.location.latitude
      lon: stationData.location.longitude
    @set 'geoPosition', pos
    @set 'name', stationData.name


  cleanupModel: =>
    @ioUnbindAll()
    return @
