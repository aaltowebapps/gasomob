###
StationsList
###
class Gaso.StationsList extends Backbone.Collection
  model  : Gaso.Station
  url    : 'stations'
  socket : window.socket

  initialize: (data) ->
    @on 'distancesChanged', _.debounce(@onDistancesChanged,100)

  # Note: Backbone sorts the collection automatically on adds and removes, but it can't know
  # what data our comparator relies upon and re-sort automatically when the data changes. Then we need to sort manually.
  comparator: (s1, s2) ->
    d1 = s1.getDistance()
    d2 = s2.getDistance()
    if d1 < d2 then -1 else if d1 > d2 then 1 else 0

  onDistancesChanged: =>
    Gaso.log "Station distances changed. Manually re-sort the collection."
    @sorted = true
    @sort()

  # Override add method to add some own logic for syncing/updating the collection.
  add: (data, options) ->
    # Single ready Stations are added when we query data e.g. from CloudMade
    if data instanceof Gaso.Station
      Gaso.log "Add single Station model to collection", data
      # Expect distance to be set for ready Station models, not testing for it
      unless @duplicateExistsAlready data
        super data, options
        # TODO The logic with this isn't bulletproof, @sorted=false can get overridden.
        # (But actually for now the result is what we want:
        # Station list renders if it contains only data acquired from external services and not from our DB and
        # the list will actually be re-sorted just as soon as the calculations complete.)
        @sorted = true
    # We get raw data arrays from our own DB
    else if data?.length
      Gaso.log "Add #{data.length} stations to collection from raw data"
      for station in data
        # Expect raw data
        if station instanceof Gaso.Station
          Gaso.fatal "Not expecting array of Station models, TODO implement"

        #TODO calculate distance/ranking here, that way we won't have to do this @sorted stuff!

        distanceSet = station.directDistance? or station.drivingDistance?
        existing = @get station.osmId
        if existing
          # Don't add existing stations, only update data
          Gaso.log "TODO Update address data for existing station ", existing, " already in collection"
          if station.prices?
            for p in station.prices
              existing.updatePriceFull p.type, p

        else
          @sorted = false unless distanceSet
          super station, options

  # Test for duplicates based on distance and brand to all stations in the collection.
  duplicateExistsAlready: (station) ->
    newStationLoc = station.get 'location'
    newStationBrand = station.get 'brand'
    for existing in @models
      dist = Gaso.geo.calculateDistanceBetween(newStationLoc, existing.get 'location')
      return true if dist < 50 and newStationBrand == existing.get('brand')
    return false
