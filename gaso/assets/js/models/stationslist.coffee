###
StationsList
###
class Gaso.StationsList extends Backbone.Collection
  model: Gaso.Station
  url: 'stations'
  socket: window.socket

  # For now using simple comparator
  comparator: (s) ->
    if ( d = s.get 'drivingDistance' )?
      return parseFloat(d)
    else if ( d = s.get 'directDistance' )?
      return parseFloat(d)
