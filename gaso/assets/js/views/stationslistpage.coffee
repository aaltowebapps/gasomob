###
Stations list
###
class Gaso.StationsListPage extends Backbone.View

  events:
    'click #fueltypes button'  : 'onSelectFuelType'
    'change #fueltypes select' : 'onSelectFuelType'
    'click .divider'           : 'toggleItems'

  constructor: (@collection, @user) ->
    @template = _.template Gaso.util.getTemplate 'list-page'
    @setElement $('<div id="page-list"/>')


  render: (eventName) ->
    @pageInitialized = false
    @$el.html @template @collection.toJSON()
    @$list = @$el.find 'ul#list-stations'
    @bindEvents()
    @renderList()
    # Note: delegateEvents() is called automatically once in View constructor, however since we re-use the list-page
    # we must make sure that event listeners are bound again when we re-visit the list page.
    @delegateEvents()
    return @

  createListDivider: (id, text) ->
    # TODO add some icon to say that "hey i'm clickable divider"
    $ '<li/>',
      id          : id
      text        : text
      class       : 'divider'
      'data-role' : 'list-divider'
    
  toggleItems: (event) ->
    $items = $(event.target).nextUntil('.ui-li-divider').toggleClass('ui-custom-hidden')

  # Avoid repeated rendering e.g. when getting multiple 'add' events -> use debouncing
  renderList: (refresh) =>
    @closeListItems()
    @listItems = []
    Gaso.log "DEBUG collection distances during list render()", @collection.models.map (n) -> n.get 'directDistance'

    # Helper variables
    itemsHTML = []
    $othersDivider = null
    $nearbyDivider = null

    # Create list items from stations collection.
    for station, i in @collection.models
      $temp = $('<div/>')
      distance = station.getDistance()
      if i == 0 and distance <= 10
        $nearbyDivider = @createListDivider 'stations-nearby', 'Stations nearby'
        $temp.append $nearbyDivider
      else if $nearbyDivider and not $othersDivider and distance > 10
        $othersDivider = @createListDivider 'stations-others', 'Other stations'
        $temp.append $othersDivider
      $temp.append @addStationListItem(station).$el
      itemsHTML.push $temp.html()

    # Show the list.
    if refresh
      @$list.fadeOut =>
        @$list.html itemsHTML.join('')
        @$list.listview 'refresh' if @pageInitialized
        @$list.fadeIn()
    else
      @$list.html itemsHTML.join('')
      if @pageInitialized
        @$list.listview 'refresh' 
        @$list.show()

  rateLimitedRenderFunc = null
  renderListRateLimited: (refresh) =>
    if rateLimitedRenderFunc?
      return rateLimitedRenderFunc(refresh);
    rateLimitedRenderFunc = _.debounce(@renderList,100)
    @renderListRateLimited(refresh);

  bindEvents: ->
    @$el.on 'pageinit', @onPageInit
    # Updates top-page fuel type selection buttons to reflect current user choice. Initial selection must be set
    # after jQM has enhanced the page content, therefore we listen to 'pagebeforeshow' event.
    @$el.on 'pagebeforeshow', @setActiveFuelTypeInput

    @collection.on 'add', @onCollectionAdd
    @collection.on 'reset', @onCollectionReset

    @user.on 'change:myFuelType', @onUserFuelTypeChanged

  close: =>
    rateLimitedRenderFunc = null
    @off()
    @$el.off 'pageinit', @onPageInit
    @$el.off 'pagebeforeshow', @setActiveFuelTypeInput
    @collection.off 'add', @onCollectionAdd
    @collection.off 'reset', @onCollectionReset
    @user.off 'change:myFuelType', @onUserFuelTypeChanged
    @closeListItems()

  closeListItems: =>
    if @listItems?
      for item in @listItems
        item.close()

  setActiveFuelTypeInput: =>
    currentFuelType = @user.get 'myFuelType'
    $inputs = @$el.find("#fueltypes").find('.ui-btn, #otherType')
    $inputToActivate = $inputs.filter(":has([data-fueltype='#{currentFuelType}'])")
    $inputs.not($inputToActivate).removeClass('ui-btn-active')
    $inputToActivate.addClass('ui-btn-active')

    # Make sure correct select option is selected on initial page render.
    $otherType = $('#otherType')
    optVal = $otherType.find("[data-fueltype='#{currentFuelType}']").val()
    $otherType.val(optVal)
    $otherType.selectmenu 'refresh'

  onPageInit: =>
    Gaso.log "Stations page initialized by jQM"
    @pageInitialized = true

  onUserFuelTypeChanged: =>
    @setActiveFuelTypeInput()
    @renderList true

  onSelectFuelType: (event) ->
    tgtType = $(event.target).attr('data-fueltype')
    unless tgtType
      # Check if some fuel type was selected from the select box
      tgtType = $(event.target).find(':selected').attr('data-fueltype')
    if tgtType
      @user.set 'myFuelType', tgtType
      @user.save()

  onCollectionReset: =>
    @renderListRateLimited true

  onCollectionAdd: (data) =>
    item = @addStationListItem data
    # The new way: Trying out alternative way of rendering the list when new stations are added.
    # Instead of adding single items to the DOM, just render the whole list again.
    # This is simpler, but lets see if this works performance-wise.
    @renderListRateLimited true

  addStationListItem: (station) =>
    newItem = new Gaso.StationListItem model: station
    @listItems.push newItem
    newItem.render()
