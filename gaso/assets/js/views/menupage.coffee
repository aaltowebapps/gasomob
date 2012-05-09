###
menupage.coffee
###
class Gaso.MenuPage extends Backbone.View
  constructor: (@user) ->
    @template = _.template Gaso.util.getTemplate 'menu-page'
    @setElement $('<div id="page-menu"/>')
    @transition = 'flip'

  render: (eventName) ->
    $(@el).html @template()
    # no model (yet)
    #$(@el).html @template @model.toJSON()
    return @
  
  close: =>
    @off
    #@model.off ...
