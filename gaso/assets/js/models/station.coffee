###
Station
###
class Gaso.Station extends Backbone.Model
  noIoBind: false
  socket: window.socket

  defaults:
    brand: ''
    name:  ''
    address: ''

    geoPosition:
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
    @set 'id', stationData.id
    if (stationData.location?)
      pos = 
        lat: stationData.location.latitude
        lon: stationData.location.longitude
    @set 'geoPosition', pos
    @set 'name', stationData.name

  cleanupModel: =>
    @ioUnbindAll()
    return @