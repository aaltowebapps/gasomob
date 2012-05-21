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
    # @renderList()
    @bindEvents()

    return @

  renderList: (refresh) =>
    Gaso.log "Render comments list", @collection, @collection.models.length
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
        @$list.fadeIn()
    else
      @$list.html itemsHTML.join('')

    # Tidy comment post dates
    @$el.find("time.timeago").timeago()

  bindEvents: ->
    @collection.on 'reset', @onCollectionReset


  close: =>
    @off()
    @collection.off 'reset', @onCollectionReset
    @closeListItems()

  closeListItems: =>
    if @listItems?
      for item in @listItems
        item.close()

  onCollectionReset: =>
    @renderList true

  addCommentListItem: (comment) =>
    newItem = new Gaso.CommentListItem model: comment
    @listItems.push newItem
    newItem.render()
