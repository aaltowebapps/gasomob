###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  render: (eventName) ->
    @$el.html @template @model.toJSON()
    return @
