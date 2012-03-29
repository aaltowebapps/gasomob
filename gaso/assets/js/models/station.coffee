###
Station
###
class window.Station extends Backbone.Model
  brand: ''
  name:  ''

  @location
  	lat: 0
  	lon: 0

  @prices
  	diesel: 0
  	E10: 0
  	octane_98: 0
 
  @services
  	air: true
  	store: true