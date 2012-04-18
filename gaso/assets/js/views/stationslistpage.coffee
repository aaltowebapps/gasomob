###
Stations list
###
class Gaso.StationsListPage extends Backbone.View

  constructor: (@collection) ->
    @template = _.template Gaso.util.getTemplate 'list-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-list"/>')


  render: (eventName) ->
    @$el.html @template @collection.toJSON()
    @$list = @$el.find 'ul#list-stations'
    # TODO tried to get rid of FOUC with slider, when moving from map page to list page. no success yet
    # @$el.trigger('create')
    # @$el.find('#ranking-slider').fadeIn()

    # Create list items from stations.
    for station in @collection.models
      @addStationListItem station

    @bindEvents()

    return @


  bindEvents: ->
    @collection.on 'add', (data) =>
      @addStationListItem data
      @$list.listview 'refresh'


  addStationListItem: (station) =>
    @$list.append new Gaso.StationListItem(model: station).render().el
