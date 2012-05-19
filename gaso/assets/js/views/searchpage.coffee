###
Search page
###
class Gaso.SearchPage extends Backbone.View

  addressSelector = '#field-address'

  constructor: (@user, @searchContext) ->
    @template = _.template Gaso.util.getTemplate 'search-page'
    @setElement $('<div id="page-search"/>')
    @transition = 'pop'

  render: (eventName) ->
    # no model (yet)
    $(@el).html @template()
    #$(@el).html @template @model.toJSON()
    @bindEvents()

    return @

  bindEvents: ->
    # Note: We need to bind on form submit like this to be able to prevent jQM/normal form processing.
    @.$('#searchform').on 'submit', @searchAddress
    @.$('#address-search').on 'click', @searchAddress
    @$el.on 'pageshow.searchpage', (event) =>
      @.$(addressSelector).focus()
  
  close: =>
    @off()
    @$el.off '.searchpage'
    @.$('#searchform').off()
    @.$('#address-search').off()
    #@user.off ...

  getSearchTerm: =>
    @.$(addressSelector).val()

  searchAddress: (event) =>
    Gaso.log "Execute address search"
    event.preventDefault()
    Gaso.helper.message 'Searching...', lifetime: 2
    coords = Gaso.geo.findAddress @getSearchTerm(), (coords) =>
      loc =
        lat: coords.lat()
        lon: coords.lng()
      @user.set 'mapCenter', loc
      @user.set 'mapZoom', 14
      Gaso.app.router.navigate "map", trigger: true

    
