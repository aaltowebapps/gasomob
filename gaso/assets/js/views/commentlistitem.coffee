class Gaso.CommentListItem extends Backbone.View

  tagName: 'li'
  

  initialize: ->
    @template = _.template Gaso.util.getTemplate 'comment-list-item'


  render: (eventName) ->
    console.log "render comment", @, Gaso.util.getTemplate('comment-list-item')
    @$el.html @template @model.toJSON()
    @bindEvents()
    return @

  bindEvents: ->
    @model.on 'clear', @close

  close: =>
    @off()
    @model.off 'clear', @close
    #@remove()
