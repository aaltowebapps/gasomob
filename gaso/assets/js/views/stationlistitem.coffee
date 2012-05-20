class Gaso.StationListItem extends Backbone.View

  tagName: 'li'

  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-list-item'


  render: (eventName) ->
    @$el.html @template @model.toJSON()
    @bindEvents()
    return @


  bindEvents: ->
    @model.on 'clear', @close


  close: =>
    @off()
    @model.off 'clear', @close
    # If removing here, the fading out of the whole list doesn't work.
    #@remove()

