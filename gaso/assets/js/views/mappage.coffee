###
Map page
###
class Gaso.MapPage extends Backbone.View

  constructor: (@model, @user) ->
    @template = _.template Gaso.util.getTemplate 'map-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-map"/>')


  render: (eventName) ->
    @$el.html @template @model.toJSON()
    @map = new google.maps.Map @$el.find("#map-canvas")[0], @user.getGoogleMapSettings()

    _.each @model.models, 
      ((station) ->
        marker = new google.maps.Marker(station.markerOptions)
        marker.setMap(@map)
      ), 
      @

    # Redraw map on jQM page change, otherwise it won't fill the screen.
    ###
     TODO the transition between pages here is still clunky. Maybe we could force
     gMaps to draw initial map larger instead of the small box
     in the top-left corner of the screen?
    ###
    @$el.on 'pageshow', (event) =>
      google.maps.event.trigger @map, 'resize'

    return @

