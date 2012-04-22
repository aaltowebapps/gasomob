###
User
###
class Gaso.User extends Backbone.Model
  id: 'localUser'
  #noIoBind: true
  localStorage: new Backbone.LocalStorage("Gaso.User")


  defaults:
    positionAccuracy: null
    position:
      lat: null
      lon: null
    # Position where user has centered the map.
    mapCenter:
      lat: 60.167
      lon: 24.955
    mapZoom: 14
    mapTypeId: 'ROADMAP'


  initialize: ->
    # Init with initial position.
    Gaso.util.getDevicePosition (error, position) =>
      if error?
        return Gaso.error "Couldn't get initial device location.\nCode: #{error.code}\nError: #{error.message}"
      @updateUserPosition null, position
      # Initialize map to device position.
      @centerOnPosition @get 'position'

    # Start watching changes in position.
    @geoWatchID = Gaso.util.watchDevicePosition @updateUserPosition
    return


  centerOnPosition: (coords) =>
    # Copy the coords to new Object to prevent accidental pointers to same Object.
    # Default to current user position if coords not given.
    newCenter = _.extend({}, coords ? @get 'position') 
    @set 'mapCenter', newCenter
    @trigger 'reCenter'
    return


  updateUserPosition: (error, position) =>
    if error?
      switch error.code
        when error.TIMEOUT
          Gaso.log "Device position watching timed out, retrying."
          @geoWatchID = Gaso.util.watchDevicePosition @updateUserPosition
        else Gaso.log "Couldn't update device location.\nCode: #{error.code}\nError: #{error.message}"
      return

    coords = position.coords
    @set 'positionAccuracy', position.accuracy
    @set 'position',
      lat: coords.latitude
      lon: coords.longitude
    @save()

