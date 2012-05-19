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
    Gaso.log "TODO bind user events"

  updateAllUsersCount: (count) =>
    @allUsersCount = count
    @trigger 'change:allUsersCount', count
