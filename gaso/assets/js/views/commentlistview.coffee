###
Comment list
###
class Gaso.CommentListView extends Backbone.View

  constructor: (@collection, @user) ->
    @template = _.template Gaso.util.getTemplate 'comments-list'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="comments-list"/>')


  render: (eventName) ->
    collection = @collection.toJSON()
    _.extend collection,
      curuser: @user.toJSON()
    @$el.html @template collection
    
    @$list = @$el.find 'ul#list-comments'
    @renderList()
    @bindEvents()

    return @

  renderList: (refresh) =>
    Gaso.log "Render comments", @collection
    @closeListItems()
    @listItems = []
    # Create list items from stations.
    itemsHTML = []
    for comment in @collection.models
      $temp = $('<div/>').append @addCommentListItem(comment).$el
      itemsHTML.push $temp.html()

    if refresh
      @$list.fadeOut =>
        @$list.html itemsHTML.join('')
        @$list.listview 'refresh'
        @$list.fadeIn()
    else
      @$list.html itemsHTML.join('')

  bindEvents: ->
    @collection.on 'add', @onCollectionAdd

  close: =>
    @off()
    @collection.off 'add', @onCollectionAdd
    @closeListItems()

  closeListItems: =>
    if @listItems?
      for item in @listItems
        item.close()

  onCollectionAdd: (data) =>
    console.log "Add comment to comment view", @, data
    item = @addCommentListItem data
    @$list.append item.el
    @$list.listview 'refresh'

  addCommentListItem: (comment) =>
    newItem = new Gaso.CommentListItem model: comment
    @listItems.push newItem
    newItem.render()
