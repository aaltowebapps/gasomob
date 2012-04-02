###
Map page
###
class window.MapPage extends Backbone.View

  constructor: (@model, @user) ->
    @template = _.template tpl.get 'map-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-map"/>')


  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    @map = new google.maps.Map(@$el.find("#map-canvas")[0], @user.myOptions)
    _.each @model.models, 
      ((station) ->
        marker = new google.maps.Marker(station.markerOptions)
        marker.setMap(@map)
      ), 
      @
    return @

