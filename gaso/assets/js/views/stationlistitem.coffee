class Gaso.StationListItem extends Backbone.View

  tagName: 'li'
  
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-list-item'

  render: (eventName) ->
    @$el.html @template @model.toJSON()
    return @
