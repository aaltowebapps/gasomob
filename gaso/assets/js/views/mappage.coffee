###
Map page
###
class window.MapPage extends Backbone.View

  constructor: (@model, @user) ->
    @template = _.template tpl.get 'map-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div/>')


  render: (eventName) =>
    $(@el).html @template @model.toJSON()
    #@listView = ...
    #map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
    map = new google.maps.Map($("#map_canvas")[0], {})
    return @

