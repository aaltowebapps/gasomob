###
StationsList
###
class Gaso.StationsList extends Backbone.Collection
  model: Gaso.Station
  url: 'stations'
  socket: window.socket

  # For now using simple comparator
  comparator: (s) ->
    d = s.get('drivingDistance') ? s.get('directDistance')
    parseFloat d
