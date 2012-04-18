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

    # TODO calculate / fetch distance from backend / cloudmade / google maps
    distance: (Math.random() * 10).toFixed(1)


  initialize: (stationData) ->
    if (stationData.location?)
      pos = 
        lat: stationData.location.latitude
        lon: stationData.location.longitude
    @set 'geoPosition', pos

  cleanupModel: =>
    @ioUnbindAll()
    return @
