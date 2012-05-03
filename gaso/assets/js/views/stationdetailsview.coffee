###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    "click #saveButton": "savePrices"
  
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  bindEvents: ->
    @$el.off 'pageshow.station-details'
    @$el.on 'pageshow.station-details', (event) =>
      console.log("pageshow station-details")
      google.maps.event.trigger @map, 'resize'
  
  render: (eventName) -> 
    @$el.attr "data-add-back-btn", "true"
    @$el.html @template @model.toJSON()
    @map = new google.maps.Map @$el.find("#small-map-canvas")[0], @getMapSettings()
    
    return @
    
  savePrices: ->
    @model.set 
      prices:
        'diesel': @.$("#dieselPrice").val()
        '95E10':  @.$("#95E10Price").val()
        '98E5':  @.$("#98E5Price").val()
        
        
  getMapSettings: =>
    center: new google.maps.LatLng(@model.get('geoPosition').lat, @model.get('geoPosition').lon)
    zoom: 14
    mapTypeId: google.maps.MapTypeId.ROADMAP