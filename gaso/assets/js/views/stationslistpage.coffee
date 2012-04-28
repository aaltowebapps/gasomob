###
Stations list
###
class Gaso.StationsListPage extends Backbone.View

  constructor: (@collection, @user) ->
    @template = _.template Gaso.util.getTemplate 'list-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-list"/>')


  render: (eventName) ->
    @$el.html @template @collection.toJSON()
    @$list = @$el.find 'ul#list-stations'
    # TODO tried to get rid of FOUC with slider, when moving from map page to list page. no success yet
    # @$el.trigger('create')
    # @$el.find('#ranking-slider').fadeIn()

    # Tried different approaches to activate button that user has selected as the fuel type.
    # @$el.find(":contains(@user.get 'myFuelType')").button()
    # and
    # @$el.trigger('create')
    # with
    # @$el.find("#fueltypes .ui-btn:contains(@user.get 'myFuelType')").addClass('ui-btn-active')


    # Create list items from stations.
    for station in @collection.models
      @addStationListItem station

    @bindEvents()

    return @

  bindEvents: ->
    @collection.on 'add', @onCollectionAdd

  close: =>
    @off()
    @collection.off 'add', @onCollectionAdd

  onCollectionAdd: (data) =>
    @addStationListItem data
    @$list.listview 'refresh'

  addStationListItem: (station) =>
    @$list.append new Gaso.StationListItem(model: station).render().el
