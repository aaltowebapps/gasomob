###
StationsList
###
class Gaso.StationsList extends Backbone.Collection
  model: Gaso.Station
  url: 'stations'
  socket: window.socket