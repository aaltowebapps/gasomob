###
Station
###
class Gaso.Station extends Backbone.Model
  noIoBind: false
  socket: window.socket
  #url: 'station'

  defaults:
    brand  : ''
    name   : ''
    
    street : ''
    city   : ''
    zip    : ''

    geoPosition:
    	lat: 0
    	lon: 0

    prices:
      diesel  : null
      "95E10" : null
      "98E5"  : null
   
    services:
      air   : true
      store : true

    directDistance  : null
    drivingDistance : null



  initialize: (stationData) ->
    # geoPosition might come also in location-property
    if stationData.location
      pos = 
        lat: stationData.location.latitude
        lon: stationData.location.longitude
      @set 'geoPosition', pos

    if not stationData.brand
      @identifyBrand stationData.name

  cleanupModel: =>
    @ioUnbindAll()
    return @

  clear: =>
    @trigger 'clear'
    @destroy

  identifyBrand: (name) =>
    Gaso.log "Identify brand from", name
    if (/abc/ig).test name
      @set 'brand', 'abc' 
    else if (/neste/ig).test name
      @set 'brand', 'nesteoil' 
    else if (/teboil/ig).test name
      @set 'brand', 'teboil'
    else if (/st1|st.*1/ig).test name
      @set 'brand', 'st1'
    else if (/shell/ig).test name
      @set 'brand', 'shell'
    else if (/seo/ig).test name
      @set 'brand', 'seo'


  calculateDistanceTo: (position) =>
    targetLatLng = new google.maps.LatLng(position.lat, position.lon)
    geoPos = @get 'geoPosition'
    myLatLng = new google.maps.LatLng(geoPos.lat, geoPos.lon)
    distMeters = google.maps.geometry.spherical.computeDistanceBetween(myLatLng, targetLatLng)
    @set 'directDistance', (distMeters / 1000).toFixed(1)
