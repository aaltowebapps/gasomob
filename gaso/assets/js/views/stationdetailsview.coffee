###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  constructor: (@station) ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  render: (eventName) ->
    $(@el).html @template context: station: @station.model.toJSON()
    return @
