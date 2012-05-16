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
    @transition = 'slide'
    @outTransition = 
      transition: 'slide'
      reverse: true
  
  render: (eventName) -> 
    @priceEdits = []
    @$el.attr "data-add-back-btn", "true"

    templateData = @station.toJSON()
    _.extend templateData,
      curuser: @user.toJSON()
    @$el.html @template templateData

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

  bindEvents: ->
    @$el.off 'pageshow.stationdetailsview'
    @$el.on 'pageshow.stationdetailsview', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter new google.maps.LatLng(@station.get('location')[1], @station.get('location')[0])
    @station.on 'change:address', @displayAddress
    @$el.on 'swiperight.stationdetailsview', (event) =>
      window.history.back()

  close: =>
    @off
    @$el.off '.stationdetailsview'
    @station.off 'change:address', @displayAddress
    for input in @priceEdits
      input.close()
    @commentsView.close()

  getMapSettings: =>
    zoom: 16
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true
    draggable: false
    disableDoubleClickZoom: true
    
  savePrices: ->
    for input in @priceEdits
      input.updateModel()
    @saveRefuel()
    @station.save()

  saveRefuel: ->
    totalAmt   = @.$('#refuel-amt').val()
    totalPrice = @.$('#refuel-price').val()
    if totalAmt and totalPrice
      @station.updatePrice @user.get('myFuelType'), totalPrice / totalAmt
      @user.get('refills').push
        station : @station.id
        amt     : totalAmt
        price   : totalPrice
        date    : new Date()
      @user.save()


  displayAddress: =>
    # We could have own view for just the address that would render automatically, but meh
    $temp = $(@template @station.toJSON())
    @$el.find('.address').fadeOut ->
      self = $(@)
      self.hide() # Is it the span or what, but without explicity hide() the fading doesn't seem to work.
      self.html $temp.find('.address').html()
      self.fadeIn()

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
    @outTransition.reverse = false
    Gaso.app.router.navigate "stationmap/#{ @station.id }", trigger: true
    @outTransition.reverse = true
