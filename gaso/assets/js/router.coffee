###
  Router(/controller) for client side.
###
class Gaso.AppRouter extends Backbone.Router

  routes:
    # Home-page
    ""                      : "home"
    # "/"                     : "showMap"
    # Other pages
    "map"                   : "showMap"
    "list"                  : "showList"
    "menu"                  : "showMenu"
    "search"                : "search"
    "settings"              : "settings"
    "stations/:id"          : "stationDetails"
    "stationmap/:id"        : "stationMap"
    "stations/:id/refuel"   : "refuel"


  initialize: ->
    @initModels()
    # Init helper controller.
    Gaso.helper = new Gaso.Helper(@user, @stations, @searchContext)
    @initViews()
    @bindEvents()
    return

  initModels: ->
    #TODO hmm should we put these into Gaso.models... or not?
    @comments           = new Gaso.CommentsList()
    @searchContext      = new Gaso.SearchContext()
    @stations           = new Gaso.StationsList()
    @user               = new Gaso.User()
    # Load cache user data directly from localstorage.
    @user.fetch()


  initViews: ->
    #TODO hmm should we put these into Gaso.views... or not?
    @listPage     = new Gaso.StationsListPage(@stations, @user)
    @settingsPage = new Gaso.UserSettingsPage(@user)
    @mapPage      = new Gaso.MapPage(@stations, @user)
    @menuPage     = new Gaso.MenuPage(@user)
    @searchPage   = new Gaso.SearchPage(@user)


  bindEvents: ->
    # Helper variables.
    self = @
    $doc = $ document

    # Fix jQM back-button behaviour.
    $doc.on 'click', '.back, [data-rel="back"]', (event) ->
      window.history.back()
      event.preventDefault()

    # Remove page from DOM when it's being replaced
    $doc.on 'pagehide', 'div[data-role="page"]', (event) ->
      Gaso.log "Remove page", @
      # Expect page-views to implement a close() -method that cleans up the view properly.
      Gaso.log "Call 'close' to ", self.prevPage
      self.prevPage?.close()
      $(@).remove()
      self.prevPage = self.currentPage



  ###
    ROUTES
  ###
  home: ->
    @navigate "map",
      trigger: true
      replace: true

  search: ->
    @changePage @searchPage

  showList: ->
    @changePage @listPage

  settings: ->
    @changePage @settingsPage

  showMap: ->
    @changePage @mapPage

  showMenu: ->
    @changePage @menuPage

  stationDetails: (id) ->
    # For now just handle as refuel, we might do something else with this later.
    @refuel id

  # TODO Refactor to DRY stationMap and refuel -functions

  stationMap: (id, noFetch) ->
    station = @stations.get(id)
    if station?
      @changePage new Gaso.StationMapPage(model: station)
    else if noFetch
      Gaso.error "The station #{id} isn't still in the collection, it probably doesn't exist in the DB. Redirect to working page."
      @navigate "map",
        trigger: true
        replace: true
    else
      $.mobile.showPageLoadingMsg()
      # This can happen e.g. if landing directly to this page e.g. from bookmark or by refreshing the browser page.
      Gaso.helper.findStationByOsmId id, (error, success) =>
        Gaso.log "Fetching done, trying to open station map page again. Response:", success
        Gaso.error "Error finding station", error if error?
        @stationMap(id, true)


  refuel: (id, noFetch) =>
    Gaso.log "Open station #{id} details: noFetch =", noFetch
    station = @stations.get(id)
    if station?
      @changePage new Gaso.StationDetailsView(station, @user, @comments)
      @comments.fetch
        data: station.id
    else if noFetch
      Gaso.error "The station #{id} isn't still in the collection, it probably doesn't exist in the DB. Redirect to working page."
      @navigate "list",
        trigger: true
        replace: true
    else
      $.mobile.showPageLoadingMsg()
      # This can happen e.g. if landing directly to this page e.g. from bookmark or by refreshing the browser page.
      Gaso.helper.findStationByOsmId id, (error, success) =>
        Gaso.log "Fetching done, trying to open station details page again. Response:", success
        Gaso.error "Error finding station", error if error?
        @refuel(id, true)

  ###
    HELPER METHODS
  ###

  # Routing tricks for changing pages with jQM.
  changePage: (page) ->
    Gaso.log 'Change to page', page
    $p = $(page.el)
    $p.attr 'data-role', 'page'
    page.render()
    $('body').append $p

    # Don't animate the first page. Use default JQM transition if nothing else defined in view.
    transition = if not @currentPage? then 'none' else page.transition or $.mobile.defaultPageTransition
    pageChangeOptions =
      changeHash: false
      transition: transition
    if @currentPage?.outTransition?
      _.extend pageChangeOptions, @currentPage.outTransition

    if Gaso.loggingEnabled()
      Gaso.log "Page change options", JSON.stringify pageChangeOptions
    # Change the JQM page.
    @currentPage = page
    $.mobile.changePage $p, pageChangeOptions


    
