###
  Router(/controller) for client side.
###
class Gaso.AppRouter extends Backbone.Router

  routes:
    # Home-page
    ""                      : "showMap"
    "/"                     : "showMap"
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

  stationMap: (id) ->
    station = @stations.get(id)
    if station?
      @changePage new Gaso.StationMapPage(model: station)
    else 
      Gaso.log 'Station not loaded, redirecting to map'
      @navigate "map",
        trigger: true
        replace: true
  
  refuel: (id) =>
    station = @stations.get(id)
    if station?
      @changePage new Gaso.StationDetailsView(station, @user, @comments)
      @comments.fetch
        data: station.id
    else
      Gaso.log 'TODO Station not loaded, redirecting to listing for now'
      # TODO fetch station in the background and e.g. and change to page after callback.
      # This can happen if landing directly to station details page or to an unknown id.
      @navigate "list",
        trigger: true
        replace: true


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

    # Change the JQM page.
    @currentPage = page
    $.mobile.changePage $p, 
      changeHash: false,
      transition: transition

    
