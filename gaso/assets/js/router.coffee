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
    @bindEvents()
    @initStaticViews()
    return

  initModels: ->
    @user               = new Gaso.User()
    @comments           = new Gaso.CommentsList()
    @searchContext      = new Gaso.SearchContext()
    @stations           = new Gaso.StationsList()
    @stations.setUser @user
    @notifications      = new Gaso.Notifications()
    @notifications.setUser @user
    # Load cached user data directly from localstorage.
    @user.fetch()

  initStaticViews: ->
    @onlineUsersView    = new Gaso.OnlineUsersView(collection: @notifications).render()
    @notificationsView  = new Gaso.NotificationView().render()

  bindEvents: ->
    # Helper variables.
    self = @
    $doc = $ document

    # Fix jQM back-button behaviour.
    $doc.on 'tap', '.back, [data-rel="back"]', (event) ->
      window.history.back()
      event.preventDefault()

    # Remove page from DOM when it's being replaced
    $doc.on 'pagehide', 'div[data-role="page"]', (event) ->
      Gaso.log "Remove page", @
      # Expect page-views to implement a close() -method that cleans up the view properly.
      Gaso.log "Call 'close' to ", self.prevPage
      self.prevPage?.close()
      # Only remove the element from the DOM like this if there's no prevPage (happens on page load).
      unless self.prevPage?
        $(@).remove()
      else
        self.prevPage?.remove()
      self.prevPage = self.currentPage


  ###
    ROUTES
  ###
  home: ->
    @navigate "map",
      trigger: true
      replace: true

  search: ->
    @changePage new Gaso.SearchPage(@user, @searchContext)

  showList: ->
    @changePage new Gaso.StationsListPage(@stations, @user)

  settings: ->
    @changePage new Gaso.UserSettingsPage(@user)

  showMap: ->
    @changePage new Gaso.MapPage(@stations, @user)

  showMenu: ->
    @changePage new Gaso.MenuPage(@user)

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
    @fixNavBar page

    # Don't animate the first page. Use default JQM transition if nothing else defined in view.
    transition = if not @currentPage? then 'none' else $.mobile.defaultPageTransition
    pageChangeOptions =
      changeHash: false
      transition: transition
    if @user.get 'useSpecialTransitions'
      if page.transition?
        pageChangeOptions.transition = page.transition
      if @currentPage?.outTransition?
        _.extend pageChangeOptions, @currentPage.outTransition
    
    Gaso.log "Page change options", JSON.stringify pageChangeOptions if Gaso.loggingEnabled()
    # Change the JQM page.
    @currentPage = page
    $.mobile.changePage $p, pageChangeOptions

  fixNavBar: (page) ->
    # Check if the page we are navigating to is one of the 'root' pages. If not found, keep the active navbar state as it is.
    if page instanceof Gaso.SearchPage
      @latestRoute = 'search'
    else if page instanceof Gaso.MapPage
      @latestRoute = 'map'
    else if page instanceof Gaso.StationsListPage
      @latestRoute = 'list'
    else if page instanceof Gaso.MenuPage
      @latestRoute = 'menu'

    # Fix the navbar in the DOM.
    page.$("#navigation a[href='##{@latestRoute}']").addClass('ui-btn-active') if @latestRoute
    
