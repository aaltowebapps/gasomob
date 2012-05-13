###
Stations list
###
class Gaso.StationsListPage extends Backbone.View

  events:
    'click #fueltypes button' : 'onSelectFuelType'
    'click .divider'          : 'toggleItems'

  constructor: (@collection, @user) ->
    @template = _.template Gaso.util.getTemplate 'list-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-list"/>')


  render: (eventName) ->
    @pageInitialized = false
    @$el.html @template @collection.toJSON()
    @$list = @$el.find 'ul#list-stations'
    @bindEvents()
    @renderList()
    # TODO tried to get rid of FOUC with slider, when moving from map page to list page. no success yet
    # @$el.trigger('create')
    # @$el.find('#ranking-slider').fadeIn()


    
    # Tried different approaches to activate button that user has selected as the fuel type.
    # @$el.find(":contains(@user.get 'myFuelType')").button()
    # and
    # @$el.trigger('create')
    # with


    # Note: delegateEvents() is called automatically once in View constructor, however since we re-use the list-page
    # we must make sure that event listeners are bound again when we re-visit the list page.
    @delegateEvents()

    return @

  createListDivider: (id, text) ->
    $ '<li/>',
      id          : id
      text        : text
      class       : 'divider'
      'data-role' : 'list-divider'
    
  toggleItems: (event) ->
    $items = $(event.target).nextUntil('.ui-li-divider').toggle()

  renderList: (refresh) =>
    @closeListItems()
    @listItems = []
    return unless @collection.sorted
    Gaso.log "DEBUG collection order during list render()", @collection.models.map (n) -> n.get 'directDistance'

    # Helper variables
    itemsHTML = []
    othersDivi = null

    # Create list items from stations collection.
    for station, i in @collection.models
      $temp = $('<div/>')
      distance = station.getDistance()
      if i == 0 and distance <= 10
        $temp.append @createListDivider 'stations-nearby', 'Stations nearby'
      else if not othersDivi and distance > 10
        othersDivi = @createListDivider 'stations-others', 'Other stations'
        $temp.append othersDivi
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

  bindEvents: ->
    @$el.on 'pageinit', @onPageInit
    @collection.on 'add', @onCollectionAdd
    @collection.on 'reset', @onCollectionReset

    # Updates top-page fuel type selection buttons to reflect current user choice. Initial selection must be set
    # after jQM has enhanced the page content, therefore we listen to 'pagebeforeshow' event.
    @$el.on 'pagebeforeshow', @setActiveFuelTypeButton
    @user.on 'change:myFuelType', @onUserFuelTypeChanged

  close: =>
    @off()
    @$el.off 'pageinit', @onPageInit
    @$el.off 'pagebeforeshow'
    @collection.off 'add', @onCollectionAdd
    @user.off 'change:myFuelType', @onUserFuelTypeChanged
    @closeListItems()

  closeListItems: =>
    if @listItems?
      for item in @listItems
        item.close()

  setActiveFuelTypeButton: =>
    currentFuelType = @user.get 'myFuelType'
    $btns = @$el.find("#fueltypes .ui-btn")
    $btnToActivate = $btns.filter(":has([data-fueltype='#{currentFuelType}'])")
    $btns.not($btnToActivate).removeClass('ui-btn-active')
    $btnToActivate.addClass('ui-btn-active')

  onPageInit: =>
    Gaso.log "Stations page initialized by jQM"
    @pageInitialized = true

  onUserFuelTypeChanged: =>
    @setActiveFuelTypeButton()
    newType = @user.get 'myFuelType'
    @renderList true

  onSelectFuelType: (event) ->
    @user.set 'myFuelType', $(event.target).attr('data-fueltype')
    @user.save()

  onCollectionReset: =>
    @renderList true

  onCollectionAdd: (data) =>
    item = @addStationListItem data
    # The old way:
    # TODO insert directly to correct index instead of just append?
    # @$list.append item.el
    # @$list.listview 'refresh'

    # The new way: Trying out alternative way of rendering the list when new stations are added.
    # Instead of adding single items to the DOM, just render the whole list again.
    # This is simpler, but lets see if this works performance-wise.
    @renderList()

  addStationListItem: (station) =>
    newItem = new Gaso.StationListItem model: station
    @listItems.push newItem
    newItem.render()
