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
    "stations/:id/refuel"   : "refuel"


  initialize: ->
    # Init models.
    #TODO hmm should we put these into Gaso.models... or not?
    @stations     = new Gaso.StationsList()
    @stations.fetch(add: true)
    @user         = new Gaso.User()
    @user.fetch()

    # Init helper controller.
    @helper = new Gaso.Helper(@user, @stations)

    # Init views.
    #TODO hmm should we put these into Gaso.views... or not?
    @listPage     = new Gaso.StationsListPage(@stations, @user)
    @settingsPage = new Gaso.UserSettingsPage(@user)
    @mapPage      = new Gaso.MapPage(@stations, @user)
    @menuPage     = new Gaso.MenuPage(@user)

    @bindEvents()
    return


  bindEvents: ->
    # Helper variables.
    self = @
    $doc = $ document

    # Fix jQM back-button behaviour.
    $doc.on 'click', '.back', (event) ->
      window.history.back()
      e.preventDefault()

    # Remove page from DOM when it's being replaced
    $doc.on 'pagehide', 'div[data-role="page"]', (event) ->
      Gaso.log "Remove page", @
      # Expect page-views to implement a close() -method that cleans up the view properly.
      Gaso.log "Call 'close' to ", self.prevPage
      self.prevPage?.close()
      $(@).remove()
      self.prevPage = self.currentPage


  search: ->
    #TODO implement search page, navigate there
    @changePage @settingsPage

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

  
  refuel: (id) =>
    station = @stations.get(id)
    if station?
      @changePage new Gaso.StationDetailsView(model: station, refuel: true)
    else
      Gaso.log 'TODO Station not loaded, redirecting to listing for now'
      # TODO fetch station in the background and e.g. and change to page after callback.
      # This can happen if landing directly to station details page or to an unknown id.
      @navigate "list",
        trigger: true
        replace: true


  # Routing tricks for changing pages with jQM.
  changePage: (page) ->
    Gaso.log 'Change to page', page
    $p = $(page.el)
    $p.attr 'data-role', 'page'
    page.render()
    $('body').append $p

    # Don't animate the first page.
    transition = if not @currentPage? then 'none' else $.mobile.defaultPageTransition
    
    # Change the JQM page.
    @currentPage = page
    $.mobile.changePage $p, 
      changeHash: false,
      transition: transition

    
