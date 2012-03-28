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
        return false

    @firstPage = true
    @stations = new StationsList
    return


  showList: ->
    @changePage new StationsListPage(model: @stations)


  settings: ->
    @changePage new UserSettingsPage

  showMap: ->
    @changePage new MapPage(model: @stations)


  stationDetails: (id) ->
    new Station(id:id).fetch
      success: (data) =>
        # TODO we might want to show station details in a dialog, popup or similar, instead of another page?
        @changePage new StationDetailsView(model: data)

  
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


# Init app on document.ready
$ -> 
  tpl.loadTemplates ['user-settings-page', 'foobar'], ->
    console.log 'Templates loaded'
    app = new AppRouter
    Backbone.history.start()
    return
  return