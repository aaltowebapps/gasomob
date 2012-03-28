###
Map page
###
class window.MapPage extends Backbone.View

  initialize: ->
    @template = _.template tpl.get 'map-page'

  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    #@listView = ...
    return @

