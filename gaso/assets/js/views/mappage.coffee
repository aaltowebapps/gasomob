###
Map page
###

class MapPage extends Backbone.View

  initialize: ->
    @template = _.template tpl.get 'map-page'

  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    #@listView = ...
    #map = new google.maps.Map(document.getElementById("map_canvas"), myOptions)
    return @

