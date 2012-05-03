###
Stations list
###
class Gaso.StationsListPage extends Backbone.View

  events:
    'click #fueltypes button' : 'onSelectFuelType'

  constructor: (@collection, @user) ->
    @template = _.template Gaso.util.getTemplate 'list-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-list"/>')


  render: (eventName) ->
    @$el.html @template @collection.toJSON()
    @$list = @$el.find 'ul#list-stations'
    @renderList()
    # TODO tried to get rid of FOUC with slider, when moving from map page to list page. no success yet
    # @$el.trigger('create')
    # @$el.find('#ranking-slider').fadeIn()


    
    # Tried different approaches to activate button that user has selected as the fuel type.
    # @$el.find(":contains(@user.get 'myFuelType')").button()
    # and
    # @$el.trigger('create')
    # with

    @bindEvents()

    # Note: delegateEvents() is called automatically once in View constructor, however since we re-use the list-page
    # we must make sure that event listeners are bound again when we re-visit the list page.
    @delegateEvents()

    return @

  renderList: (refresh) =>
    @closeListItems()
    @listItems = []
    console.log "DEBUG collection order during list render()", @collection.models.map (n) -> n.get 'directDistance'
    # Create list items from stations.
    itemsHTML = []
    for station in @collection.models
      $temp = $('<div/>').append @addStationListItem(station).$el
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

    # Updates top-page fuel type selection buttons to reflect current user choice. Initial selection must be set
    # after jQM has enhanced the page content, therefore we listen to 'pagebeforeshow' event.
    @$el.on 'pagebeforeshow', @setActiveFuelTypeButton
    @user.on 'change:myFuelType', @onUserFuelTypeChanged

  close: =>
    @off()
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

  onUserFuelTypeChanged: =>
    @setActiveFuelTypeButton()
    newType = @user.get 'myFuelType'
    @renderList true

  onSelectFuelType: (event) ->
    @user.set 'myFuelType', $(event.target).attr('data-fueltype')
    @user.save()

  onCollectionAdd: (data) =>
    item = @addStationListItem data
    @$list.append item.el
    @$list.listview 'refresh'

  addStationListItem: (station) =>
    newItem = new Gaso.StationListItem model: station
    @listItems.push newItem
    newItem.render()
