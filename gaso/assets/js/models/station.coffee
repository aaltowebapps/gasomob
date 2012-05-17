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
    
    address:
      country: ''
      city   : ''
      street : ''
      zip    : ''

    # Expected to be an array [lon, lat]. Note: our geospatial queries in the backend depend on the order to be correct.
    location: null
    services: null
    prices: null

    directDistance  : null
    drivingDistance : null

  ###
   All the models will share reference to same object/array, if we define object- or array-default values
   in the defaults-hash. Then we'll get into huge problems very easily.
   See e.g. http://stackoverflow.com/questions/6433795/backbone-js-handling-of-attributes-that-are-arrays
  ###
  setNonPrimitiveDefaults: (initData) ->
    @set 'location', [] unless initData.location?
    @set 'services', [] unless initData.services?
    defaultPrices = [
      type: "95E10"
    ,
      type: "98E5"
    ,
      type: "Diesel"
    ]
    # TODO Improve: this is a bit hackish way of ensuring we have our default types listed in station details
    if initData.prices?
      for def in defaultPrices
        typeExists = _.find initData.prices, (p) -> p.type == def.type
        unless typeExists
          initData.prices.push def
    @set 'prices', defaultPrices unless initData.prices?

  initialize: (stationData) ->
    @setNonPrimitiveDefaults stationData
    @identifyBrand stationData.name unless stationData.brand
    @on 'change:directDistance change:drivingDistance', @onDistanceChanged

  onDistanceChanged: =>
    @collection.trigger 'distancesChanged' if @collection?

  cleanupModel: =>
    @ioUnbindAll()
    @off()
    return @

  clear: =>
    @trigger 'clear'
    @cleanupModel()
    @destroy

  updatePrice: (type, value) =>
    prices = @get 'prices'
    pricesUpdated = _updatePrice prices, type, value
    # Modifying the array won't automatically trigger backbone event, lets trigger it ourself.
    @trigger 'change:prices', @ if pricesUpdated

  updateAddress: ->
    # Don't update if we don't have coordinates or address is already set.
    loc = @get 'location'
    return if not loc?
    # Test just the street
    return if @get 'street'

    Gaso.geo.getAddress loc, (addr) =>
      @set 'address', addr

  getLatLng: =>
    loc = @get 'location'
    return lat: loc[1], lon: loc[0]

  getDistance: ->
    d = @get('drivingDistance') ? @get('directDistance')
    parseFloat d

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


  ###
    Private helper methods etc.
  ###


  ###
    Helper method to update price for given type.
    @return false If a) value hasn't changed or b) trying to set empty or 0 value. Otherwise return true.
  ###
  _updatePrice = (prices, type, value) ->
    return false if !value

    value = parseFloat(value).toFixed(3)

    currPrice = _.find prices, (p) -> p.type == type
    if not currPrice?
      # Given fuel type not in prices array at all, add it.
      prices.push
        type  : type
        value : value
      return true

    # Type exists in array, update only if value has changed.
    return false if currPrice.value == value

    currPrice.value = value
    return true

