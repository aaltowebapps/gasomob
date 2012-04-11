

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
    "settings"              : "settings"
    "stations/:id"          : "stationDetails"
    "stations/:id/refuel"   : "refuel"


  initialize: ->
    $(document).on 'click', '.back', (event) ->
      window.history.back()
      e.preventDefault()

    @firstPage = true
    
    # Init models.
    #TODO hmm should we put these into Gaso.models... or not?
    @stations     = new Gaso.StationsList()
    @stations.fetch(add: true)
    @user         = new Gaso.User()
    @user.fetch()

    # Init views.
    #TODO hmm should we put these into Gaso.views... or not?
    @listPage     = new Gaso.StationsListPage(@stations, @user)
    @settingsPage = new Gaso.UserSettingsPage(@stations, @user)
    @mapPage      = new Gaso.MapPage(@stations, @user)

    return


  showList: ->
    @changePage @listPage

  settings: ->
    @changePage @settingsPage

  showMap: ->
    @changePage @mapPage


  stationDetails: (id) ->
    new Gaso.Station(id:id).fetch
      success: (data) =>
        # TODO we might want to show station details in a dialog, popup or similar, instead of another pagechangePage
        @? new Gaso.StationDetailsView(model: data)

  
  refuel: (id) ->
    new Gaso.Station(id:id).fetch
      success: (data) =>
        console.log "Fetched station data", data
        # TODO we might want to show station details in a dialog, popup or similar, instead of another page?
        @changePage new Gaso.StationDetailsView(model: data, refuel: true)


  # Routing tricks for changing pages with jQM.
  changePage: (page) ->
    console.log 'Change to page', page
    $p = $(page.el)
    $p.attr 'data-role', 'page'
    page.render()
    $('body').append $p
    transition = $.mobile.defaultPageTransition

    # Don't slide the first page
    if @firstPage
      transition = 'none'
      @firstPage = false 
    
    # Change the JQM page
    $.mobile.changePage $p, 
      changeHash: false,
      transition: transition
    return