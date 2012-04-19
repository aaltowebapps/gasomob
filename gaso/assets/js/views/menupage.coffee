###
menupage.coffee
###
class Gaso.MenuPage extends Backbone.View
  constructor: (@model, @user) ->
    @template = _.template Gaso.util.getTemplate 'menu-page'
    @setElement $('<div id="page-menu"/>')

  render: (eventName) ->
    $(@el).html @template @model.toJSON()
    return @
  