###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    "click #saveButton": "savePrices"
  
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  render: (eventName) -> 
    @$el.attr "data-add-back-btn", "true"
    @$el.html @template @model.toJSON()
    return @
    
  savePrices: ->
    @model.set 
      prices:
        'diesel': @.$("#dieselPrice").val()
        '95E10':  @.$("#95E10Price").val()
        '98E5':  @.$("#98E5Price").val()
