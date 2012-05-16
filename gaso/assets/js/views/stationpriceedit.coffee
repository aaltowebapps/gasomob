class Gaso.StationPriceEdit extends Backbone.View

  # events:
  #   # To update model directly without needing a 'save'-button... good or bad?
  #   "change": "updateModel"

  constructor: (@model, @price) ->
    @template = _.template Gaso.util.getTemplate 'price-edit'
    @setElement $('<div data-role="fieldcontain"/>') # class="ui-hide-label"

  render: (eventName) -> 
    @$el.html @template @price
    console.log "pricee", JSON.stringify @price
    @$el.find("time.timeago").timeago()
    return @
    
  updateModel: ->
    @model.updatePrice @price.type, @.$('.price-input').val()

  close: =>
    @off
    #@model.off ...


