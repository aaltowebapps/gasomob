###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    "click #saveButton": "savePrices"
    'change #addOtherPrice select': "addOtherPriceEdit"
  
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  bindEvents: ->
    @$el.off 'pageshow.stationdetailsview'
    @$el.on 'pageshow.stationdetailsview', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter new google.maps.LatLng(@model.get('location')[1], @model.get('location')[0])
  
  render: (eventName) -> 
    @priceEdits = []
    @$el.attr "data-add-back-btn", "true"

    @$el.html @template @model.toJSON()
    
    @map = new google.maps.Map @$el.find("#small-map-canvas")[0], @getMapSettings()
    new Gaso.StationMarker(@model, @map).render()

    @$prices = @$el.find '#prices'

    for price in @model.get 'prices'
      @addPriceEdit price
    
    @bindEvents()
    
    return @
    
  getMapSettings: =>
    zoom: 14
    mapTypeId: google.maps.MapTypeId.ROADMAP
    
  savePrices: ->
    for input in @priceEdits
      input.updateModel()
    @model.save()

  close: =>
    @off
    #@model.off ...
    for input in @priceEdits
      input.close()


  addPriceEdit: (price, options) =>
    defaults =
      animate: false
    settings = _.extend {}, defaults, options

    newEdit = new Gaso.StationPriceEdit @model, price
    @priceEdits.push newEdit
    $edit = newEdit.render().$el

    if settings.animate
      $edit.hide()
    @$prices.append $edit
    if settings.animate
      $edit.addClass('ui-field-contain ui-body ui-br').trigger('create')
      $edit.slideDown()


  addOtherPriceEdit: (event) ->
    $select = $(event.target)
    selectedType = $select.val()
    if selectedType
      p =
        type: $select.val()
      $select.find(':selected').remove()
      $select.val('').selectmenu('refresh')
      @addPriceEdit p, animate: true
