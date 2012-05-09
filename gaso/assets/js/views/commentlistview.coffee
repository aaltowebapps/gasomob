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
    @listInitialized = false
    @bindEvents()
    @renderList()

    return @

  renderList: (refresh) =>
    Gaso.log "Render comments", @collection, @collection.models.length
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
        @$list.listview 'refresh' if @listInitialized
        @$list.fadeIn()
    else
      @$list.html itemsHTML.join('')

  bindEvents: ->
    @$list.on 'create', @onListInitialized
    @collection.on 'reset', @onCollectionReset

  onListInitialized: =>
    Gaso.log "Comments list initialized by jQM"
    @listInitialized = true

  onCollectionReset: =>
    @renderList true

  close: =>
    @off()
    @$list.off 'create', @onListInitialized
    @collection.off 'reset', @onCollectionReset
    @closeListItems()

  closeListItems: =>
    if @listItems?
      for item in @listItems
        item.close()

  addCommentListItem: (comment) =>
    newItem = new Gaso.CommentListItem model: comment
    @listItems.push newItem
    newItem.render()
