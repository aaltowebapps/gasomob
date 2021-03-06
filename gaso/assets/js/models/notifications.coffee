class Gaso.Notifications extends Backbone.Collection
  noIoBind : false
  socket   : window.socket
  url      : 'notifications'

  allUsersCount: 0
  cityUsersCount: 0

  initialize: ->
    @ioBind 'allUsersCount', @updateAllUsersCount

  cleanupCollection: =>
    @ioUnbindAll()
    @off()
    return @

  clear: =>
    @trigger 'clear'
    @cleanupCollection()

  setUser: (user) ->
    @user = user
    @bindUserEvents()

  bindUserEvents: ->
    Gaso.log "TODO bind user events (e.g. when user's city changes, join a socketio room for that city)"

  updateAllUsersCount: (count) =>
    unless count == @allUsersCount
      @allUsersCount = count
      @trigger 'change:allUsersCount', count
