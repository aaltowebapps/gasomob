###
  Main initialization for clientside
###
class AppRouter extends Backbone.Router

  routes:
    # Home-page
    ""                      : "showMap"
    # Other pages
    "list"                  : "showList"
    "map"                   : "showMap"
    "settings"              : "settings"
    "stations/:id"          : "stationDetails"
    "stations/:id/refuel"   : "refuel"


  initialize: ->
    $(document).on 'click', '.back', (event) ->
        window.history.back()
        e.preventDefault()

    @firstPage = true
    
    dummyStations = [
      (new Station (
        'name': 'Testiasema',
        'location':
          'latitude': '60.167',
          'longitude': '24.955'
      )),
      (new Station (
        'name': 'Toinen mesta',
        'location':
          'latitude': '60.169696',
          'longitude': '24.938536'
      )),
      (new Station (
        'name': 'Kolmas mesta',
        'location':
          'latitude': '60.16968',
          'longitude': '24.945'
      ))]
    
    @stations = new StationsList(dummyStations)
    
    @user = new User
    return


  showList: ->
    @changePage new StationsListPage(@stations, @user)

  settings: ->
    @changePage new UserSettingsPage(model: @user)

  showMap: ->
    @changePage new MapPage(@stations, @user)


  stationDetails: (id) ->
    new Station(id:id).fetch
      success: (data) =>
        # TODO we might want to show station details in a dialog, popup or similar, instead of another pagechangePage
        @? new StationDetailsView(model: data)

  
  refuel: (id) ->
    new Station(id:id).fetch
      success: (data) =>
        # TODO we might want to show station details in a dialog, popup or similar, instead of another page?
        @changePage new StationDetailsView(model: data, refuel: true)


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


# Init app
tpl.loadTemplates ['user-settings-page', 'map-page', 'list-page'], ->
  console.log 'Templates loaded'
  app = new AppRouter
  Backbone.history.start()
  #app.navigate("map", {trigger: true})
