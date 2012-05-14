###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    "click #saveButton": "savePrices"
    'change #addOtherPrice select': "addOtherPriceEdit"
    'click #small-map-canvas': 'openLargeMap'
    'tap #small-map-canvas': 'openLargeMap'

  constructor: (@station, @user, @comments) ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
  
  bindEvents: ->
    @$el.off 'pageshow.stationdetailsview'
    @$el.on 'pageshow.stationdetailsview', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter new google.maps.LatLng(@station.get('location')[1], @station.get('location')[0])
  
  render: (eventName) -> 
    @priceEdits = []
    @$el.attr "data-add-back-btn", "true"

    @$el.html @template @station.toJSON()

    @station.updateAddress()
    
    @map = new google.maps.Map @$el.find("#small-map-canvas")[0], @getMapSettings()
    
    marker = new Gaso.StationMarker(@station, @map, noAnimation: true).render()
    google.maps.event.clearInstanceListeners(marker.marker)

    # Render comments
    @commentsView = new Gaso.CommentListView(@comments, @user).render()
    @$comments = @$el.find '#comments'
    @$comments.append(@commentsView.el)

    @$prices = @$el.find '#prices'

    for price in @station.get 'prices'
      @addPriceEdit price
    
    @bindEvents()
    
    return @
    
  getMapSettings: =>
    zoom: 16
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
    draggable: false
    disableDoubleClickZoom: true
    
  savePrices: ->
    for input in @priceEdits
      input.updateModel()
    @station.save()

  close: =>
    @off
    #@station.off ...
    for input in @priceEdits
      input.close()
    @commentsView.close()


  addPriceEdit: (price, options) =>
    defaults =
      animate: false
    settings = _.extend {}, defaults, options

    newEdit = new Gaso.StationPriceEdit @station, price
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
    Gaso.app.router.navigate "stationmap/#{ @station.id }", trigger: true
