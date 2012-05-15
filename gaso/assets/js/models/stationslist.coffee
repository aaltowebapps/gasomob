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
    Gaso.log "Station distances changed. Manually re-sort of the collection."
    @sorted = true
    @sort()

  add: (data, options) ->
    if data instanceof Gaso.Station
      Gaso.log "Add single Station model to collection", data
      # Expect distance to be set for ready Station models
      super data, options
    else
      Gaso.log "Add stations to collection, should be an array of raw data objects", data
      for tation in data
        # Expect raw data
        if station instanceof Gaso.Station
          Gaso.fatal "Not expecting array of Station models, TODO implement"

        distanceSet = station.directDistance? or station.drivingDistance?
        existing = @get station.osmId
        if existing
          # Don't add existing stations, only update data
          Gaso.log "Station", existing, "already in collection, update prices etc, if available ", station.prices
        else
          @sorted = false unless distanceSet
          super station, options

