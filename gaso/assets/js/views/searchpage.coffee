###
Search page
###
class Gaso.SearchPage extends Backbone.View
  constructor: (@user, @searchContext) ->
    @template = _.template Gaso.util.getTemplate 'search-page'
    @setElement $('<div id="page-search"/>')
    @transition = 'pop'

  render: (eventName) ->
    $(@el).html @template()
    # no model (yet)
    #$(@el).html @template @model.toJSON()
    return @
  
  close: =>
    @off()
    #@model.off ...
