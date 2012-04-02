###
Stations list
###
class window.StationsListPage extends Backbone.View

  constructor: (@collection) ->
    @template = _.template tpl.get 'list-page'
    # TODO for some reason we must explicitly call setElement, otherwise view.el property doesn't exist?
    @setElement $('<div id="page-list"/>')

  render: (eventName) ->
    $(@el).html @template @collection.toJSON()
    return @