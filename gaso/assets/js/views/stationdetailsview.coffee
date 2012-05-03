###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    'click #saveButton': 'savePrices'
    'change #addOtherPrice select': 'addOtherPriceEdit'
    'click #small-map-canvas': 'openLargeMap'
    'tap #small-map-canvas': 'openLargeMap'
  
  initialize: ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  getMapSettings: =>
    zoom: 16
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
    draggable: false
    disableDoubleClickZoom: true

  render: (eventName) -> 
    @priceEdits = []
    @$el.attr "data-add-back-btn", "true"

    @$el.html @template @model.toJSON()

    @model.updateAddress()
    
    @map = new google.maps.Map @$el.find("#small-map-canvas")[0], @getMapSettings()
    marker = new Gaso.StationMarker(@model, @map).render()
    google.maps.event.clearInstanceListeners(marker.marker)

    @$prices = @$el.find '#prices'

    for price in @model.get 'prices'
      @addPriceEdit price
    
    @bindEvents()
    
    return @

  bindEvents: ->
    @$el.off 'pageshow.stationdetailsview'
    @$el.on 'pageshow.stationdetailsview', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter Gaso.geo.latLonTogMapLatLng @model.get('location')
    @model.on 'change:address', @displayAddress

  close: =>
    @off
    @$el.off 'pageshow.stationdetailsview'
    @model.off 'change:address', @displayAddress
    #@model.off ...
    for input in @priceEdits
      input.close()

  displayAddress: =>
    # We could have own view for just the address that would render automatically, but meh
    $temp = $(@template @model.toJSON())
    @$el.find('.address').fadeOut ->
      self = $(@)
      self.hide() # Is it the span or what, but without explicity hide() the fading doesn't seem to work.
      self.html $temp.find('.address').html()
      self.fadeIn()
  
  savePrices: ->
    for input in @priceEdits
      input.updateModel()
    @model.save()


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

  openLargeMap: ->
    Gaso.app.router.navigate "stationmap/#{ @model.id }", trigger: true
    
