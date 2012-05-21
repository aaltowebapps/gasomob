###
stationdetailsview.coffee
###
class Gaso.StationDetailsView extends Backbone.View
  events:
    "tap #saveButton": "savePrices"
    'change #addOtherPrice select': "addOtherPriceEdit"
    'tap #small-map-canvas': 'openLargeMap'

  constructor: (@station, @user, @comments) ->
    @template = _.template Gaso.util.getTemplate 'station-details'
    @setElement $('<div id="station-details"/>')
    @transition = 'slide'
    @outTransition = 
      transition: 'slide'
      reverse: true
    
  
  getTemplateData: ->
    templateData = @station.toJSON()
    _.extend templateData,
      curuser: @user.toJSON()
    return templateData

  render: (eventName) -> 
    @priceEdits = []
    @$el.attr "data-add-back-btn", "true"

    @$el.html @template @getTemplateData()

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
    @$el.on 'pageshow.stationdetailsview', (event) =>
      google.maps.event.trigger @map, 'resize'
      @map.setCenter new google.maps.LatLng(@station.get('location')[1], @station.get('location')[0])
    if @user.get 'useSwipeToGoBack'
      @$el.on 'swiperight.stationdetailsview', (event) =>
        window.history.back()

    @station.on 'change:address', @displayAddress
    @station.on 'sync', @displaySaveSuccess

  close: =>
    google.maps.event.clearInstanceListeners @map
    @map = null
    @off()
    @$el.off '.stationdetailsview'
    @station.off 'change:address', @displayAddress
    @station.off 'sync', @displaySaveSuccess
    for input in @priceEdits
      input.close()
    @commentsView.close()

  getMapSettings: =>
    zoom                   : 16
    mapTypeId              : google.maps.MapTypeId.ROADMAP
    disableDefaultUI       : true
    draggable              : false
    disableDoubleClickZoom : true
    
  savePrices: ->
    for input in @priceEdits
      input.updateModel()
    @saveRefuel()
    Gaso.helper.message 'Saving...'
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
        # TODO we could allow user to choose some other date
        date    : new Date()
      @user.save()


  displayAddress: =>
    # We could have own view for just the address that would render automatically, but meh
    $temp = $(@template @getTemplateData())
    @$el.find('.address').fadeOut ->
      self = $(@)
      self.hide() # Is it the span or what, but without explicity hide() the fading doesn't seem to work.
      self.html $temp.find('.address').html()
      self.fadeIn()

  displaySaveSuccess: =>
    Gaso.helper.message 'Saved!', lifetime: 2, replace: true

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
