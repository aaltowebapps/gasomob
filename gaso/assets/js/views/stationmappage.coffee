###
Map page for a single station
###
class Gaso.StationMapPage extends Backbone.View
  initialize: ->
    console.log "model", @model
    @template = _.template Gaso.util.getTemplate 'station-map-page'
    @setElement $('<div id="page-station-map"/>')
    
    
  render: =>
    @$el.html @template @model.toJSON()
    @$el.attr "data-add-back-btn", "true"
    
    @map = new google.maps.Map @$el.find("#station-map-canvas")[0], @getInitialMapSettings()
    marker = new Gaso.StationMarker(@model, @map).render()
    # Don't clear listeners to allow user to come back to details page also by clicking the marker again.
    # If user for some reason comes to station page from an external link,
    # the back button would just take them away from the site.
    # google.maps.event.clearInstanceListeners(marker.marker)

    @bindEvents()

    return @
    

  bindEvents: ->
    @$el.off 'pageshow.stationmappage'
    @$el.on 'pageshow.stationmappage', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter new google.maps.LatLng(@model.get('location')[1], @model.get('location')[0])
      
      
  close: =>
    @off


  getInitialMapSettings: =>
    zoom: 15
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: productionEnv
    
