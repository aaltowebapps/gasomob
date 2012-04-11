###
Map page
###
class Gaso.MapPage extends Backbone.View

  markers: []

  constructor: (@stations, @user) ->
    @template = _.template Gaso.util.getTemplate 'map-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-map"/>')
    # TODO now updating markers on all model events, modify event bindings to 'change', 'add', etc. as needed
    @stations.on 'all', @updateMarkers



  updateMarkers: =>
    # TODO could improve this to only remove "deprecated" markers and update the existing ones as needed.

    _.each @markers, (marker) ->
      marker.setMap null

    _.each @stations.models, (station) =>
      marker = new google.maps.Marker(station.markerOptions)
      marker.setMap @map
      @markers.push marker



  render: (eventName) =>
    console.log "Map page render triggered from event", eventName
    @$el.html @template @stations.toJSON()
    @map = new google.maps.Map @$el.find("#map-canvas")[0], @user.getGoogleMapSettings()

    @updateMarkers()

    # Redraw map on jQM page change, otherwise it won't fill the screen.
    ###
     TODO the transition between pages here is still clunky. Maybe we could force
     gMaps to draw initial map larger instead of the small box
     in the top-left corner of the screen?
    ###
    @$el.on 'pageshow', (event) =>
      google.maps.event.trigger @map, 'resize'

    return @

