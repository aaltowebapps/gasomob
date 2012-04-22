# Couldn't come up with a better name for a business logic handling / helper controller...
class Gaso.Helper

  constructor: (@user, @stations) ->
    @stations.on 'add', @calculateDistance
    @user.on 'change:position', @updateDistances


  calculateDistance: (station) =>
    userpos = @user.get 'position'
    # Don't do anything if user geolocation is not set.
    return if not (userpos.lat? and userpos.lon?)
    station.calculateDistanceTo userpos


  updateDistances: =>
    for station in @stations.models
      @calculateDistance station
