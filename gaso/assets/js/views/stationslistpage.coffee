###
Stations list
###
class StationsListPage extends Backbone.View

  initialize: ->
    @template = _.template tpl.get 'stations-list'

  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    return @
  