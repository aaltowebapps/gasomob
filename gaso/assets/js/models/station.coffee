###
Station
###
class Gaso.Station extends Backbone.Model
  noIoBind: false
  socket: window.socket
  url: 'station'
  idAttribute: 'osmId'

  defaults:
    brand  : ''
    name   : ''
    
    street : ''
    city   : ''
    zip    : ''

    # Expected to be an array [lon, lat]. Note: our geospatial queries in the backend depend on the order to be correct.
    location: []

    # TODO modify prices to be an array of objects
    prices:
      diesel  : null
      "95E10" : null
      "98E5"  : null
   
    services: []

    directDistance  : null
    drivingDistance : null



  initialize: (stationData) ->
    @identifyBrand stationData.name unless stationData.brand

  cleanupModel: =>
    @ioUnbindAll()
    return @

  clear: =>
    @trigger 'clear'
    @destroy


  getLatLng: =>
    loc = @get 'location'
    return lat: loc[1], lon: loc[0]

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


