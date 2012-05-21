###
StationsList
###
class Gaso.StationsList extends Backbone.Collection
  model  : Gaso.Station
  url    : 'stations'
  socket : window.socket

  initialize: (data) ->
    @setDistancePriceFactor 50
    @on 'distancesChanged', _.debounce(@onDistancesChanged,100)

  setUser: (user) ->
    @user = user
    @bindUserEvents()
    @setDistancePriceFactor user.get('distancePriceFactor')

  setDistancePriceFactor: (value) ->
    val = parseFloat(value) / 100
    return if isNaN val
    if not @distancePriceFactor? or @distancePriceFactor != val
      @distancePriceFactor = val
      @reCalculateRankings()
      @sort()

  bindUserEvents: ->
    # TODO we don't have event unbinding / cleanup for stations collection, but on the other hand (so far) we have
    # only one stations collection object that we always use and never destroy.
    @user.on 'change:myFuelType', @onUserFuelTypeChanged
    @user.on 'change:distancePriceFactor', @onUserDPFactorChanged


  # Note: Backbone sorts the collection automatically on adds and removes, but it can't know
  # what data our comparator relies upon and re-sort automatically when the data changes. Then we need to sort manually
  # if we modify data later.
  comparator: (s1, s2) ->
    r1 = s1.ranking
    r2 = s2.ranking
    if r1 < r2 then -1 else if r1 > r2 then 1 else 0

  calculateRanking: (station) ->
    fueltype       = @user.get 'myFuelType'
    priceFactor    = 1 - @distancePriceFactor
    distanceFactor = @distancePriceFactor

    if priceFactor == 1
      rank = station.getPrice(fueltype)?.value or Infinity
    else if distanceFactor == 1
      rank = station.getDistance()
    else 
      priceIndex = _.indexOf @modelsSortedByPrice, station
      distanceIndex = _.indexOf @modelsSortedByDistance, station
      rank = priceFactor * priceIndex + distanceFactor * distanceIndex

    Gaso.log "Factor: ", @distancePriceFactor, "-> rank for station", station.id, station.get('name'), '=', rank if Gaso.loggingEnabled()
    return rank

  reCalculateRankings: =>
    return unless @user?
    fueltype                = @user.get 'myFuelType'
    @modelsSortedByPrice    = _.sortBy @models, (m) -> m.getPrice(fueltype)?.value or Infinity
    @modelsSortedByDistance = _.sortBy @models, (m) -> m.getDistance()
    Gaso.log "stations sorted by price", @modelsSortedByPrice.map (n) -> n.getPrice(fueltype)?.value
    Gaso.log "stations sorted by distance", @modelsSortedByDistance.map (n) -> n.get 'directDistance'
    for station in @models
      station.ranking = @calculateRanking station


  # Sort with some extras.
  sortAndCleanup: ->
    @reCalculateRankings()
    @sort silent: true
    @cleanupList()
    @trigger 'reset'
    
  onUserFuelTypeChanged: =>
    Gaso.log "User fuel type changed. Manually re-sort the collection."
    @sortAndCleanup()

  onUserDPFactorChanged: =>
    Gaso.log "User changed distance price factor. Manually re-sort the collection."
    @setDistancePriceFactor @user.get('distancePriceFactor')
    @sortAndCleanup()    

  onDistancesChanged: =>
    Gaso.log "Station distances changed. Manually re-sort the collection."
    @sortAndCleanup()

  # Override add method to add some own logic for syncing/updating the collection.
  # For example we need to calculate/update some properties for the models (that are needed in comparator) prior to
  # adding the models collection for automatic sorting to work. 
  add: (data, options) ->
    needManualSort = false
    # Single ready Stations are added when we query data e.g. from CloudMade
    if data instanceof Gaso.Station
      Gaso.log "Add single Station model to collection", data
      # Expect distance to be set for ready Station models, not testing for it
      unless @duplicateExistsAlready data
        @setRequiredModelProperties data
        super data, options
    # We get raw data arrays (or nulls) from our own DB
    else if data?.length
      Gaso.log "Add #{data.length} stations to collection from raw data"
      for station in data
        # Expect raw data
        if station instanceof Gaso.Station
          Gaso.fatal "Not expecting array of Station models, TODO implement"

        existing = @get station.osmId
        if existing
          # Don't add existing stations, only update data
          Gaso.log "TODO Update address data for existing station ", existing, " already in collection"
          if station.prices?
            for p in station.prices
              # Updating of prices will cause sorting order to go stale.
              # TODO Now we don't actually check if prices were really modified, we should.
              needManualSort = true
              existing.updatePriceFull p.type, p

        else
          stationModel = new Gaso.Station station
          @setRequiredModelProperties stationModel
          super stationModel, options
    # At the end of add do manual sorting and/or cleanup.
    if needManualSort then @sortAndCleanup() else @cleanupList()

  setRequiredModelProperties: (stationModel) ->
    stationModel.addedToList = new Date()
    Gaso.helper.setDistanceToUser stationModel
    stationModel.ranking = @calculateRanking stationModel

  # Test for duplicates based on distance and brand to all stations in the collection.
  duplicateExistsAlready: (station) ->
    newStationLoc = station.get 'location'
    newStationBrand = station.get 'brand'
    for existing in @models
      dist = Gaso.geo.calculateDistanceBetween(newStationLoc, existing.get 'location')
      return true if dist < 50 and newStationBrand == existing.get('brand')
    return false

  # Prevent performance problems by cleaning up old models
  cleanupList: =>
    limit = 100
    modelsSortedByDate = _.sortBy @models, (m) -> -m.addedToList
    for m, i in modelsSortedByDate
      # TODO here we could/should prevent top-ranked stations to be dropped off from the collection?
      if i >= limit
        @remove m.id
        m.clear()

