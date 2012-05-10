class Gaso.CommentListItem extends Backbone.View

  tagName: 'li'
  

  initialize: ->
    @template = _.template Gaso.util.getTemplate 'comment-list-item'


  render: (eventName) ->
    @$el.html @template @model.toJSON()
    @bindEvents()
    return @

  bindEvents: ->
    @model.on 'clear', @close

  close: =>
    @off()
    @model.off 'clear', @close
    #@remove()
