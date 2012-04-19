###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  render: (eventName) -> 
    @$el.attr "data-add-back-btn", "true"
    @$el.html @template @model.toJSON()
    return @
